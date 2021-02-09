function menu() 
{
    do
    {
        Clear-Host
        Write-Host "
            #----------------------------------------------------------#
            #                 Server Statitics                         #
            #                                                          #
            #                                                          #
            #   1. Disk information                                    #
            #   2. Logons since restart                                #
            #   3. List of critical errors                             #
            #                                                          #
            #   5. Uptime                                              #
            #   9. Run all & Export to txt                             #
            #   0. End                                                 #
            #                                                          #
            #                                                          #
            #----------------------------------------------------------#
            "
        $hovedmenu = read-host "Indtast valgmulighed"

        switch ($hovedmenu)
        {
            1 {GetDiskInfo}
            2 {GetLogon}
            3 {GetError}

            5 {GetUpTime}
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
function GetDiskInfo(){
    Write-host "Scanning disks ... Please be patient"
    #vælger at benytte get-wmiobjectet, hvor jeg bruger klassen
    #win32_logicaldisk. For kun at få en fixed disk type, så vælges drivetypen
    #at være 3, hvor 4. eks. vil være netværksdrev. 
    Get-WmiObject -class Win32_Logicaldisk | where drivetype -eq 3 | foreach-object {
    #har valgt at lave noget exception handling her, da der godt kan opstå fejl
    #med mine udregninger hvis den ikke kan finde filstørrelsen på drevet. 
       try{
            #har valgt at explicit typecaste mine variable, for at sørge for at
            #den ikke få vanvittig mange decimaler på
            [int]$gb_size = $_.Size * 1.0E-9
            [int]$gb_Freespace = $_.FreeSpace * 1.0E-9
            [int]$gb_used = $gb_size - $gb_Freespace
            [int]$percentage = ($gb_used / $gb_size) *100
            write-host "Information of drive:" $_.name
            write-host "Drive size:" $gb_size "GB" 
            write-host "Used space:" $gb_used "GB ($percentage %)" 
            write-host "Free drive size:" $gb_Freespace "GB" 
            Timeout /t 30
       }
       catch{
            write-host $Error[0]
       }
       
    }
}

function GetLogon(){
    #benytter get-ciminstance objektet med win32_operating system, hvoraf 
    #lastbootuptime bruges til at gå ind i eventloggen og sammenligne
    #informationerne med typen winLogon. 
    $lastboot = Get-CimInstance -ClassName win32_operatingsystem | select  lastbootuptime
    Get-EventLog System -Source Microsoft-Windows-WinLogon -After ($lastboot.LastBootUpTime) | format-list Username, Source, TimeGenerated
    timeout /t 30
}

function GetError(){
    #Benytter get-eventlog objektet, med parameteren -Logname som gør at vi jan
    #vælge hvilken logbog vi vil slå op i, i dette tilfælde har vi valgt System.
    #Vi vælger også, at det skal være en error, ellers gider vi ikke se på det. 
    #henter errors der er 30 dage gamle 
    Get-EventLog -LogName System -EntryType Error -After (Get-Date).Adddays(-30)
    timeout /t 30
}

function GetUpTime(){
    $date = (get-date) #henter dagens dato og gemmer den i en variable
    #Henter sidste gang computeren blev startet og gemmer i en variable
    $lastboottime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    # med disse informationer kan vi nu trække dagensdato fra sidste gang den
    # har været startet, for at få uptime. 
    $date - $lastboottime
    timeout /t 30
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
    GetDiskInfo
    GetLogon
    GetError
    GetUpTime
    Stop-Transcript 
    write-host "Scan complete, you can find the new file at:" $DesktopPath
    Timeout /T 10
}
function LukMeny
{
    Write-Host 'Så lukker vi bixen ;-)' 
    sleep 3
}
menu