{ pkgs, ... }:
let
  # Cornix は wsl.vil 1枚に統一し、macOS 側で grave(0x35) ↔ non-US backslash(0x64) を
  # スワップして吸収する(macOS が ISO 配列の ` と § を入れ替えて解釈するため)。
  # ID は USB / Bluetooth LE どちらの接続でも同一(確認済み)。
  vendorId = 57624; # 0xE118
  productId = 1;

  matching = [
    {
      VendorID = vendorId;
      ProductID = productId;
    }
  ];

  hidUsagePageKeyboard = 30064771072; # 0x700000000
  grave = hidUsagePageKeyboard + 53; # 0x35
  nonUsBackslash = hidUsagePageKeyboard + 100; # 0x64

  keyMapping = [
    {
      HIDKeyboardModifierMappingSrc = grave;
      HIDKeyboardModifierMappingDst = nonUsBackslash;
    }
    {
      HIDKeyboardModifierMappingSrc = nonUsBackslash;
      HIDKeyboardModifierMappingDst = grave;
    }
  ];

  remapScript = pkgs.writeShellScript "cornix-remap" ''
    /usr/bin/hidutil property \
      --matching '${builtins.toJSON matching}' \
      --set '${builtins.toJSON { UserKeyMapping = keyMapping; }}'
  '';
in
{
  launchd.user.agents.cornix-remap = {
    serviceConfig = {
      ProgramArguments = [ "${remapScript}" ];
      # ログイン時に適用し、Cornix の USB 接続でも再適用する
      # (hidutil の UserKeyMapping はデバイスの抜き差しで消えるため)
      RunAtLoad = true;
      LaunchEvents = {
        "com.apple.iokit.matching" = {
          # USB 接続時
          cornix-usb = {
            IOProviderClass = "IOUSBDevice";
            idVendor = vendorId;
            idProduct = productId;
            IOMatchLaunchStream = true;
          };
          # HID デバイス出現時(Bluetooth LE を含む全トランスポート)
          cornix-hid = {
            IOProviderClass = "IOHIDDevice";
            IOPropertyMatch = {
              VendorID = vendorId;
              ProductID = productId;
            };
            IOMatchLaunchStream = true;
          };
        };
      };
    };
  };
}
