# Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
# THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 
# We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that. 
# You agree: 
# (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
# (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; 
# and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code 



function get-AccessTokenAsUser{
    param (
        [parameter(Mandatory=$true)]
        [string]$ResourceUri,
        [parameter(Mandatory=$false)]
        [string]$AuthorityUri="https://login.windows.net/",
        [parameter(Mandatory=$true)]
        [string]$ClientID,
        [parameter(Mandatory=$false)]
        [string]$TenantID,
        [parameter(Mandatory=$true)]
        [string]$redirectUri
    )
    if($TenantID -eq $null){
        $TenantID="common"
    }
    if($AuthorityUri -eq 'https://login.windows.net/'){
        $endpoint = $AuthorityUri + $TenantID + "/oauth2/authorize"
    }else{
        $endpoint = $AuthorityUri
    }

    $authContext = new-object Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext($endpoint)
    $authParam = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters("always")
    try{
        $result = $authContext.AcquireTokenAsync($ResourceUri, $ClientID, $redirectUri,$authParam)

        #waiting task Complete
        while (!$result.IsCompleted) {
            Start-Sleep -Seconds 1            
        }

        if($result.status -eq 'Faulted'){
            throw $result.Exception.InnerException
        }
        return $result.Result
    }catch{
        throw
    }
}

function get-AccessTokenAsClient{
    param (
        [parameter(Mandatory=$true)]
        [string]$ResourceUri,
        [parameter(Mandatory=$false)]
        [string]$AuthorityUri="https://login.windows.net/",
        [parameter(Mandatory=$true)]
        [string]$ClientID,
        [parameter(Mandatory=$true)]
        [string]$TenantID,
        [parameter(Mandatory=$true)]
        [string]$ClientSecret
    )
    $endpoint = $AuthorityUri + $TenantID + "/oauth2/authorize"

    try{
        $authContext = new-object Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext($endpoint , $false)
        $ClientCred = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential($ClientID,$ClientSecret)
        $result = $authContext.AcquireTokenAsync($ResourceUri, $ClientCred)

        #waiting task Complete
        while (!$result.IsCompleted) {
            Start-Sleep -Seconds 1            
        }
                  
        if($result.status -eq 'Faulted'){

            throw $result.Exception.InnerException
        } 
        return $result.Result
    }catch{
        throw
    }
}
function get-AccessTokenAsClientwithCert{
    param (
        [parameter(Mandatory=$true)]
        [string]$ResourceUri,
        [parameter(Mandatory=$false)]
        [string]$AuthorityUri="https://login.windows.net/",
        [parameter(Mandatory=$true)]
        [string]$ClientID,
        [parameter(Mandatory=$true)]
        [string]$TenantID,
        [parameter(Mandatory=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate]$certificate
    )
    $endpoint = $AuthorityUri + $TenantID + "/oauth2/authorize"

    try{
        $authContext = new-object Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext($endpoint , $false)
        $ClientCred = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.ClientAssertionCertificate($ClientID, $certificate)

        $result = $authContext.AcquireTokenAsync($ResourceUri, $ClientCred)

        #waiting task Complete
        while (!$result.IsCompleted) {
            Start-Sleep -Seconds 1            
        }
                  
        if($result.status -eq 'Faulted'){

            throw $result.Exception.InnerException
        } 
        return $result.Result
    }catch{
        throw 
    }
}
function get-AuthorizationHeader{
    param(
        [parameter(Mandatory=$true)]
        [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationResult]$AccessToken
    )
    $headers = @{
        'Authorization'="$($AccessToken.AccessTokenType) $($AccessToken.AccessToken)"
        'content-Type'= "application/json"
        }
    
    return $headers

}
