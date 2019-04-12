# PSADAL

## 導入方法

```Powershell
Import-Module <モジュールを保存したパス>\PSADAL
```

## 使用方法

このモジュールでは以下のコマンドレットが利用できます。

```PowerShell
Get-AccessTokenAsUser
Get-AccessTokenAsClinet
Get-AccessTokenAsClientwithCert
Get-AuthorizationHeader
```

### 1. ユーザーとしてトークンを取得する(Get-AccessTokenAsUser)
Native アプリケーションにおいて、Client Secret を用いず、ユーザー認証によってトークンを取得します。

```Powershell
Get-AccessTokenAsUser `
-ClientID <アプリケーション ID> `
-ResourceURI <リソース URI> `
-RedirectURI <Redirect URI> `
-TenantID <テナント名> `
```

実行例
```PowerShell
Get-AccessTokenAsUser `
-ClientID "21ede95b-5994-2137-b191-cad5daea005d" `
-ResourceURI  "https://graph.microsoft.com" `
-RedirectURI "http://localhost" `
-TenantID "contoso.onmicrosoft.com" `
```


実行結果
```
AccessTokenType       : Bearer
AccessToken           : eyJ0eXAiOiJKV1QiLCJub25jZSI6IkFRQUJBQUFBQUFEQ29N <snip>
ExpiresOn             : 2019/04/12 8:52:06 +00:00
ExtendedLifeTimeToken : False
TenantId              : 1e21412a-fd5e-42e3-b5da-53dc51163e42
UserInfo              : Microsoft.IdentityModel.Clients.ActiveDirectory.UserInfo
IdToken               : eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJhdWQiOiJl <snip>

Authority             : https://login.windows.net/test.onmicrosoft.com/oauth2/authorize/
```


### 2. アプリケーションとしてトークンを取得する(Get-AccessTokenAsClient)
Web アプリケーションにおいて、Client Secret を用いて、トークンを取得します。

```Powershell
Get-AccessTokenAsUser `
-ClientID <アプリケーション ID> `
-ResourceURI <リソース URI> `
-RedirectURI <Redirect URI> `
-TenantID <テナント名> `
```

実行例
```PowerShell
get-AccessTokenAsClient  `
-ClientID "52828bf0-353e-4357-aed4-b0c277d72254" `
-ResourceURI  "https://graph.microsoft.com" `
-TenantID "contoso.onmicrosoft.com" `
-ClientSecret "CvI4y+XAJMgUpomHYUBBSIJNEwo+BSLVhU6uSpRtPCI="
```

実行結果
```
AccessTokenType       : Bearer
AccessToken           : eyJ0eXAiOiJKV1QiLCJub25jZSI6IkFRQUJBQUFBQUFEQ29 <smip>
ExpiresOn             : 2019/04/12 9:00:52 +00:00
ExtendedLifeTimeToken : False
TenantId              :
UserInfo              :
IdToken               :
Authority             : https://login.windows.net/contoso.onmicrosoft.com/oauth2/authorize/
```


### 3. アプリケーションとして証明書を用いてトークンを取得する(Get-AccessTokenAsClientwithCert)
Web アプリケーションにおいて、証明書を用いてトークンを取得します。

```Powershell
Get-AccessTokenAsUser `
-ClientID <アプリケーション ID> `
-ResourceURI <リソース URI> `
-RedirectURI <Redirect URI> `
-TenantID <テナント名> `
```

実行例
```PowerShell

$Cert=Get-ChildItem "cert:\CurrentUser\My"|where {$_.Thumbprint -eq '<Thumbprint>'}

> $cert


   PSParentPath: Microsoft.PowerShell.Security\Certificate::CurrentUser\My

Thumbprint                                Subject
----------                                -------
<Thumbprint>                              CN=MytestApp


get-AccessTokenAsClientwithCert  `
-ClientID "52828bf0-353e-4357-aed4-b0c277d72254" `
-ResourceURI  "https://graph.microsoft.com" `
-TenantID "contoso.onmicrosoft.com" `
-certificate $Cert
```

実行結果
```
AccessTokenType       : Bearer
AccessToken           : eyJ0eXAiOiJKV1QiLCJub25jZSI6IkFRQUJBQUFBQUFEQ29 <smip>
ExpiresOn             : 2019/04/12 10:01:06 +00:00
ExtendedLifeTimeToken : False
TenantId              :
UserInfo              :
IdToken               :
Authority             : https://login.windows.net/myrasame.onmicrosoft.com/oauth2/authorize/
```


### 4. 取得したトークンを AuthHeader 用のハッシュテーブルに成形する(Get-AuthorizationHeader)

```PowerShell
$token=get-AccessTokenAsClientwithCert  `
-ClientID "52828bf0-353e-4357-aed4-b0c277d72254" `
-ResourceURI  "https://graph.microsoft.com" `
-TenantID "contoso.onmicrosoft.com" `
-certificate $Cert

$header = Get-AuthorizationHeader -AccessToken $token

> $header

Name                           Value
----                           -----
content-Type                   application/json
Authorization                  Bearer eyJ0eXAiOiJKV1QiLCJ <snip> zF1RE...


> Invoke-WebRequest `
-Uri "https://graph.microsoft.com/v1.0/me" `
-Headers $header


StatusCode        : 200
StatusDescription : OK
Content           : {"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#users/$entity","businessPhones":[],"d
                    isplayName":"syncadmin","givenName":null,"jobTitle":null,"mail":"testuser@contoso.onmicrosoft.com
                    ",...
RawContent        : HTTP/1.1 200 OK
                    Transfer-Encoding: chunked
                    request-id: d01ff59d-4719-4914-8b00-8d2f7e60f82a
                    client-request-id: d01ff59d-4719-4914-8b00-8d2f7e60f82a
                    x-ms-ags-diagnostic: {"ServerInfo":{"DataCenter"...
Forms             : {}
Headers           : {[Transfer-Encoding, chunked], [request-id, d01ff59d-4719-4914-8b00-8d2f7e60f82a], [client-request-
                    id, d01ff59d-4719-4914-8b00-8d2f7e60f82a], [x-ms-ags-diagnostic, {"ServerInfo":{"DataCenter":"Japan
                     East","Slice":"SliceC","Ring":"5","ScaleUnit":"002","RoleInstance":"AGSFE_IN_2","ADSiteName":"JPE"
                    }}]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 385
```




