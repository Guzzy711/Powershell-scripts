function menu() 
{
    do
    {
        Clear-Host
        Write-Host "
            #----------------------------------------------------------#
            #                Basic Server information                  #
            #                                                          #
            #                                                          #
            #   1. Operativ system information                         #
            #   2. Patch level information                             #
            #   3. Network information                                 #
            #                                                          #
            #   5. Share rights                                        #
            #   6. Startup service information                         #
            #   7. Date & time since restart                           #
            #                                                          #
            #   8. PowerShell Version                                  #
            #   9. Run all & Export to txt                             #
            #   0. End                                                 #
            #                                                          #
            #                                                          #
            #----------------------------------------------------------#
            "
        $hovedmenu = read-host "Indtast valgmulighed"

        switch ($hovedmenu)
        {
            1 {OsInfo}
            2 {PatchInfo}
            3 {NetworkInfo}

            5 {RightsShare}
            6 {StartupServices}
            7 {RestartInfo}

            8 {PSVersion}
            9 {ExportTxt}
            0 {LukMeny}
            #hvis forkert valg starter man forfra til hovedmenu funktion
            default 
            {
                Write-Host -ForegroundColor red "Forkert valgmulighed"
                sleep 2
            }
        }
    } until ($hovedmenu -eq 0)
}

function OsInfo(){
    #bernytter objektet get-comptuerinfo , hvor jeg bruger formatering til at
    #vise de mest nyttige informationer
    Get-ComputerInfo | format-list WindowsCurrentVersion, WindowsInstallationType, WindowsProductName, BiosName, OsBootDevice, OsLanguage  
    timeout /T 30
}

function PatchInfo(){
    #benytter objectet WMIobject, som er en instans af windows management
    #instrumentation klassen. Her sorteres der efter description, og der vises
    #kun de nyttige ting
    Get-WmiObject win32_quickfixengineering | sort-object Description | format-table HotfixID, Description, InstalledBy, InstalledOn
    timeout /T 30
}

function NetworkInfo(){
    #benytter objektet win32_networkadapterconfig objektet, hvoraf jeg vælger
    #kun at vise de interfaces der er aktive. Efterfølgende bliver der også
    #formateret, således at vi får de nødvendige info. 
    Get-WmiObject Win32_NetworkAdapterConfiguration | Where IPEnabled | format-list Description,IPSubnet, IPAddress, DefaultIPGateway, DNSDomain
    timeout /T 30
}

function RightsShare(){
    #Benytter objektet Get-PSDRive som indeholder drives på maskinen. For ikke
    #at få alle mulige underlige "drev", vælges typen filesystem, og da vi kun
    #er interesseret i stien på dette drev, så vælges root. Da den giver os
    #flere objekter, og er vi nødt til at at benytte foreach-object for at loope
    #igennem de forskellige objekter for at se rettighederne på disse drev.
    Get-PSDrive -PSProvider filesystem | select-object Root | foreach-object {
        Write-host "Rights information in " $_.Root
        (Get-acl $_.Root).Access | format-list IdentityReference,FileSystemRights
    }
   
    
}

function StartupServices(){
    Write-host "These are the services that start automatically"
    #Benytter get-service hvor starttypen er automatisk, da det må være det der
    #starter op når windows er bootet. Derudover vælges der name og starttype
    #properties. 
    get-service | where starttype -eq "automatic" | select -property name,starttype | format-table
    timeout /T 30
}

function RestartInfo(){
    Get-CimInstance -ClassName win32_operatingsystem | select CsName, LastBootUpTime | format-table 
    timeout /T 30
}

function ExportTxt(){
    #Denne funktion har til formål at kalle alle ovenstående funktionerne og så exportere
    #deres output til en .txt fil på skrivebordet. For at gemme outputtet, er
    #transcripe blevet brugt, hvoraf parameteren -outputdirectory er benyttet,
    #da den så selv finder ud af filnavn. 
    #henter brugeren desktop path, da den godt kan ændre sig fra maskine til maskine.
    $DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
    write-host "Scanning system .. Please wait, this might take up to 5mins"
    Start-Transcript -OutputDirectory $DesktopPath -Confirm 
    OsInfo
    PatchInfo
    NetworkInfo
    RightsShare
    StartupServices
    RestartInfo
    Stop-Transcript 
    write-host "Scan complete, you can find the new file at:" $DesktopPath
    Timeout /T 10
}

function LukMeny
{
    Write-Host 'Så lukker vi bixen ;-)' 
    sleep 3
}


function PSVersion
{
    $PSVersionTable.PSVersion
    Write-Host 'Tast enter' -NoNewline
    timeout /T 30
}
menu