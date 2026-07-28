" Neovim 同梱の syntax/vb.vim は VB6 世代で、VB.NET (VB7+) のキーワードを知らない。
" Imports / Class / Inherits / Try / Of などが素の色のまま残るため、ここで補う。
" 実測で「同梱 vb.vim がハイライトしない語」だけを列挙している（重複指定は無害だが増やさない）。
"
" LINQ のクエリキーワード (Where / Group / Take / By / Into / Equals ...) は
" 意図的に入れていない。VB は syn case ignore かつこれらは文脈依存キーワードなので、
" 同名の変数やメソッド (obj.Equals など) を誤って色付けする害が大きい。

" 宣言・修飾子・制御構文
syn keyword vbStatement Imports Namespace Class Module Structure Interface Delegate
syn keyword vbStatement Inherits Implements Partial MustInherit NotInheritable Shadows
syn keyword vbStatement Overrides Overridable NotOverridable Overloads Operator
syn keyword vbStatement Shared Protected ReadOnly Default Custom Iterator
syn keyword vbStatement Widening Narrowing AddHandler RemoveHandler Handles
syn keyword vbStatement Try Catch Finally Throw Using SyncLock Continue
syn keyword vbStatement Async Await Yield Strict Infer

" 式レベルのキーワード
syn keyword vbKeyword MyBase MyClass Of Global GetType
syn keyword vbKeyword DirectCast TryCast CType TypeOf IsNot AndAlso OrElse

" VB6 に無い組み込み型
syn keyword vbTypes Char Short SByte UShort UInteger ULong
