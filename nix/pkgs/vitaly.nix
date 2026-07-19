# VIA/Vial キーボードを CLI で操作するツール (https://github.com/bskaplou/vitaly)。
# nixpkgs 未収録のため crates.io からビルドする。cornix-sync.nix から使う。
{
  lib,
  stdenv,
  rustPlatform,
  fetchCrate,
  pkg-config,
  udev,
}:
rustPlatform.buildRustPackage rec {
  pname = "vitaly";
  version = "0.1.32";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-DICX1rgC/TovTK1eicQMZRSh/jJjp8R0xW0WyUZdFmQ=";
  };

  # cargoHash (fetchCargoVendor) は使わない: この nixpkgs ピンの
  # fetch-cargo-vendor-util が python-requests の User-Agent で crates.io に
  # 403 で弾かれるため、crate 同梱の Cargo.lock から importCargoLock で
  # 依存を取得する (nix 標準 fetcher なら 403 にならない)。
  cargoLock.lockFile = "${src}/Cargo.lock";

  # hidapi が Linux では libudev を要求する。macOS は apple-sdk 既定で足りる。
  nativeBuildInputs = lib.optionals stdenv.isLinux [ pkg-config ];
  buildInputs = lib.optionals stdenv.isLinux [ udev ];

  meta = {
    description = "VIA/Vial command line tool";
    homepage = "https://github.com/bskaplou/vitaly";
    license = lib.licenses.gpl2Only;
    mainProgram = "vitaly";
  };
}
