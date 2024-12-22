# PoC用自己署名証明書

[Learn](https://learn.microsoft.com/ja-jp/azure/application-gateway/self-signed-certificates)の手順で作成したもの。

## ルートCA証明書


- 秘密鍵作成

    ```
    openssl ecparam -out contoso.key -name prime256v1 -genkey
    ```

- 証明書署名要求 (CSR) を生成  
  Common Name:`www.contoso.com`

    ```
    openssl req -new -sha256 -key contoso.key -out contoso.csr
    ```

- ルート証明書を生成

    ```
    openssl x509 -req -sha256 -days 365 -in contoso.csr -signkey contoso.key -out contoso.crt
    ```

## サーバー証明書

- 秘密鍵作成

    ```
    openssl ecparam -out fabrikam.key -name prime256v1 -genkey
    ```
- 証明書署名要求 (CSR) を生成  
  Common Name:`www.fabrikam.com`

    ```
    openssl req -new -sha256 -key fabrikam.key -out fabrikam.csr
    ```

- ルート証明書を生成

    ```
    openssl x509 -req -in fabrikam.csr -CA  contoso.crt -CAkey contoso.key -CAcreateserial -out fabrikam.crt -days 365 -sha256
    ```

- 証明書を検証

    ```
    openssl x509 -in fabrikam.crt -text -noout
    ```

- crtをpfxに変換。  
  Pass:`www.fabrikam.com`

    ```
    openssl pkcs12 -export -in fabrikam.crt -inkey fabrikam.key -out fabrikam.pfx
    ```
