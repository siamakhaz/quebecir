########
# $Cred=@{}
# if (Test-Path -Path "Cred.json")
#     {
#         $Cred = Get-Content -Path "Cred.json" | ConvertFrom-Json
#         $Telegramtoken = $Cred.TelegramToken
#         $OpenAIKey= $Cred.OpenAIToken
#     }
# else {
#     Throw "Cred.json not Found!"
    
#     # Write-host -ForegroundColor red "Please make Cred.json and provide tokkens"
#     # Write-Host -ForegroundColor Blue "Please enter Telegram Token"
#     # $Telegramtoken = Read-Host -MaskInput
#     # Write-Host -ForegroundColor Blue "Please enter OpenAI"
#     # $OpenAIKey = Read-Host -MaskInput        
#     # $Cred["TelegramToken"]=$Telegramtoken
#     # $Cred["OpenAIToken"]=$OpenAIKey
#     # $Cred | ConvertTo-Json | Out-File -FilePath "Cred.json"

# }
# if (!(Test-Path -Path "Data"))
# {
#     mkdir Data   
# }


function Get-TBotInfo {
    param (
        [Parameter(Mandatory=$true)]$Telegramtoken   
    )
    $headers=@{}
    $headers.Add("accept", "application/json")
    $uri="https://api.telegram.org/bot$($Telegramtoken)/getMe"
    $Response = Invoke-RestMethod -Uri $uri 
    return $Response
}
Function Send-Telegram {
    Param([Parameter(Mandatory=$true)][String]$Message,
    [Parameter(Mandatory=$true)]$Telegramtoken,
    [Parameter(Mandatory=$true)][String]$ChatId
    )
    $uri="https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($ChatId)&parse_mode=HTML&text=$($Message)"
    
    if ($debug){ Write-Host $uri}
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Response = Invoke-RestMethod -Uri $uri 
    return $Response
}

Function get-Telegram {        
    param(
        [Parameter(Mandatory=$true)]$Telegramtoken
    )
    $uri="https://api.telegram.org/bot$($Telegramtoken)/getUpdates"        
    if (Test-Path -Path "./Data/lastupdate.json")
    {
        $lastupdateid = Get-Content -Path "./Data/lastupdate.json" | ConvertFrom-Json        
        $uri="https://api.telegram.org/bot$($Telegramtoken)/getUpdates?offset=$($lastupdateid+1)"        
    }
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Response = Invoke-RestMethod -UseBasicParsing -Uri $uri 
    $lastupdateid=($Response.result.update_id | measure -Maximum).Maximum
    if($lastupdateid){
        $lastupdateid | ConvertTo-Json | Out-File -FilePath "./Data/lastupdate.json"
    }
    return $Response
}

function Get-AskChatGPT {
    param (
        $prompt,
        [Parameter(Mandatory=$true)]$OpenAIKey
    )
    $headers = @{"Authorization" = "Bearer $OpenAIKey"}    
    if ($null -eq $prompt)
    {
        $prompt = "french quote"
    }
    do {
        $response = Invoke-RestMethod -Method Post -Uri "https://api.openai.com/v1/completions" -Headers $headers -ContentType "application/json" -Body (@{ prompt = $prompt; max_tokens = 1000; temperature = 0.5; model = "text-davinci-003" } | ConvertTo-Json)    
        Start-Sleep -Milliseconds 100
    } until (
        $null -ne $response.choices[0].text 
    )
    return $response.choices[0].text
}
