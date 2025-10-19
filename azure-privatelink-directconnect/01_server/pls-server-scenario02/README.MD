## Virtual Machine

- SSH公開鍵認証でBastionから接続する。
  - OSユーザー名はvariable.tfのvm_usernameに定義。
  - SSH秘密鍵はtfファイルと同一フォルダに出力される。

-  VM
  - カスタムスクリプトを利用してNGINXをインストールしている。
  - Server VMにPort80でHTTPアクセスすると、ホスト名を表示したHTMLページを返却する。
