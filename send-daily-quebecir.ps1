$Telegramtoken = "6258988051:AAFoX0IN3XZDUc-OLt7w3V7hj9dVu0tHRsU"
$OpenAIToken = "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"
if (!(Test-Path -Path "Data"))
{
    mkdir Data   
}

# ..\Supabase-Module\Supabase.ps1
. .\TL-Base.ps1

function send-currency {
    param (
        $currency,
        $chatid,
        $Telegramtoken
    )
    $file=Get-ChildItem -Path .\Data\navasan.json

    if ($file.LastWriteTime.DayOfYear -eq $(Get-Date).DayOfYear) {
        <# Action to perform if the condition is true #>
        $navasan=Get-Content -Path .\Data\navasan.json | ConvertFrom-Json -AsHashtable
    }
    else {
        <# Action when all if and elseif conditions are false #>
        $rates=Invoke-RestMethod -Uri "http://api.navasan.tech/latest/?api_key=freeKDZGcDTlul0hAApHujULqvN3Lixf"
        $rates | Out-File -FilePath "./Data/navasan.json"
        $navasan=$rates | ConvertFrom-Json -AsHashtable        
    }

    # $cads=$navasan.GetEnumerator() | Where-Object {$_ -like "cad"}
    # $content = "Cad to IRR :$($navasan.cad.value)`nDate: $($navasan.cad.date)"
    $content = "قیمت امروز دلار کانادا  :$($navasan.cad.value)تومان `nتاریخ: $($navasan.cad.date)`n<a href='https://fa.navasan.net/havale_canada.php'>مرجع سایت نوسان</a> "
    Send-TelegramTextMessage -BotToken $Telegramtoken -ChatID $chatid -Message $content -ParseMode HTML #-1001942280822 
    # Send-Telegram -ChatId 95589475 -Message $content 
    # $data=Get-Supabase -table "data"
    # $data= $data | ConvertFrom-Json -AsHashtable


    # Add-Supabase -table "data" -data @{"id"=$data.id.Length+1;"created_at"="now()";"Name"="Navasan";"Value"=$rates}
    # Update-Supabase -table "data" -data @{"id"=1;"created_at"="now()";"Name"="Navasan";"Value"=$rates}

    # $id=Get-Supabase -table "data" -query "select=id" 
    # Send-Telegram -ChatId 95589475 -Message $content

}
while (1) {
    if (Test-Path -Path "./Data/lastrun-quebecirbot.json")
    {
        $LastRun = Get-Content -Path "./Data/lastrun-quebecirbot.json" | ConvertFrom-csv
    }
    else 
    {
        $LastRun = (Get-Date).AddDays(-10)
    }

    if ((NEW-TIMESPAN -Start $LastRun.DateTime -End (Get-Date)).Days -gt 1)
    {
        send-currency -currency "cad" -chatid -1001942280822 -Telegramtoken $Telegramtoken
        if ($debug){Write-Host "get new qute"}
        $msg=Get-AskChatGPT -OpenAIKey $OpenAIToken -prompt "give me a poem in persian with name of poet and the name of the poem in persian language"
        Send-TelegramTextMessage -BotToken $Telegramtoken -ChatID -1001942280822 -Message $msg -ParseMode HTML #-1001942280822 
            foreach ($chatid in $chatids) {                
                Send-Telegram -Message $msg -ChatId $chatid                                    
            } 
        Get-Date | ConvertTo-csv | Out-File -FilePath "./Data/lastrun-quebecirbot.json"
    }

    Start-Sleep 1
}