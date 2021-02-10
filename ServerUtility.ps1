function menu() 
{
    do
    {
        Clear-Host
        Write-Host "
            #----------------------------------------------------------#
            #                Basic Server Utility                      #
            #                                                          #
            #                                                          #
            #   1. Operativ system information                         #
            #   2. Patch level information                             #
            #   3. Network information                                 #
            #   4. Create Virtual Machine                              #
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
            4 {UtilizeVM}
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
    write-host "#----------Operating System Information----------#"
    #bernytter objektet get-comptuerinfo , hvor jeg bruger formatering til at
    #vise de mest nyttige informationer
    Get-ComputerInfo | format-list WindowsCurrentVersion, WindowsInstallationType, WindowsProductName, BiosName, OsBootDevice, OsLanguage  
    write-host "#------------------------------------------------#"
    timeout /T 30

}

function PatchInfo(){
    write-host "#----------Update information----------#"
    #benytter objectet WMIobject, som er en instans af windows management
    #instrumentation klassen. Her sorteres der efter description, og der vises
    #kun de nyttige ting
    Get-WmiObject win32_quickfixengineering | sort-object Description | format-table HotfixID, Description, InstalledBy, InstalledOn
    write-host "#--------------------------------------#"
    timeout /T 30
}

function NetworkInfo(){
    write-host "#----------Network Information----------#"
    #benytter objektet win32_networkadapterconfig objektet, hvoraf jeg vælger
    #kun at vise de interfaces der er aktive. Efterfølgende bliver der også
    #formateret, således at vi får de nødvendige info. 
    Get-WmiObject Win32_NetworkAdapterConfiguration | Where IPEnabled | format-list Description,IPSubnet, IPAddress, DefaultIPGateway, DNSDomain
    write-host "#---------------------------------------#"
    timeout /T 30
}

function RightsShare(){
    write-host "#----------Share rights-----------#"
    #Benytter objektet Get-PSDRive som indeholder drives på maskinen. For ikke
    #at få alle mulige underlige "drev", vælges typen filesystem, og da vi kun
    #er interesseret i stien på dette drev, så vælges root. Da den giver os
    #flere objekter, og er vi nødt til at at benytte foreach-object for at loope
    #igennem de forskellige objekter for at se rettighederne på disse drev.
    Get-PSDrive -PSProvider filesystem | select-object Root | foreach-object {
        Write-host "Rights information in " $_.Root
        (Get-acl $_.Root).Access | format-list IdentityReference,FileSystemRights
    }
   write-host "#----------------------------------#"
    
}

function StartupServices(){
    write-host "#----------Startup services-----------#"
    #Benytter get-service hvor starttypen er automatisk, da det må være det der
    #starter op når windows er bootet. Derudover vælges der name og starttype
    #properties. 
    get-service | where starttype -eq "automatic" | select -property name,starttype | format-table
    write-host "#-------------------------------------#"
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
    write-host "#----------Scanning system .. Please wait, this might take up to 5mins-----------#"
    Start-Transcript -OutputDirectory $DesktopPath -Confirm 
    OsInfo
    PatchInfo
    NetworkInfo
    RightsShare
    StartupServices
    RestartInfo
    Stop-Transcript 
    write-host "Scan complete, you can find the new file at:" $DesktopPath
    write-host "#------------------------------------------------#"
    Timeout /T 10
}

function UtilizeVM(){
    #Denne funktion står for at gøre alt klar til at lave en VM. Dvs. at den
    #skal gøre alt klar til vores CreateVM funktion. 
    #Det skal være muligt at tage brugerinput som f.eks. hvor den virtuelle
    #maskine skal gemmes, navn på den og størrelse. 
    #Endvidere skal den også stå for, hvad der sker hvis der ikke bliver sat
    #noget ind i de 3 variabler fra brugeren. Den vil dertil automatisk udfylde
    #variablerne. 
    write-host "#----------VM Creation utility-----------#"
    [string]$VM_path = read-host "Specify where your VM should be saved"
    [string]$VM_name = read-host "Specify a name for your VM"
    [int]$VM_size = read-host "Specify size of your VM"
    #Jeg bliver nødt til at tjekke om disse variabler er sat, for de er
    #afgørende for at lave en VM. 
    if(-not ([string]::IsNullOrEmpty($VM_path)) -AND -not ([string]::IsNullOrEmpty($VM_name)) -AND -not ([string]::IsNullOrEmpty($VM_size))){ #Hvis disse variabler ikke er tomme eller NULL, så 
         #tilføjer lige at det skal være i gb. 
        CreateVM $VM_path $VM_name $VM_size #kalder funktionen CreateVM med argumenterne sti, navn og størrelse
    }
    #Hvis disse tre værdier ikke bliver sat, så skal der bruges default værdier
    else{
        New-item -path $home"\VMUtility\VMs" -itemType Directory #laver en ny mappe i homedirectory for brugeren
        $VM_path = $home + "\VMUtility\VMs" #benytter den nye mappe som path
        echo $VM_path
        [string]$random_nmb = get-random #generere et random tal
        [string]$VM_name = $env:computername + "-VM-" + $random_nmb #VM navnet bliver lavet ud fra pc-navnet samt det random generede tal. Hvis der ikke er specificeret en parameter i get-random laver den et tal fra 0 - 2,147,487,647 
        [int]$Vm_size = 50
         #statisk værdi der er sat til 50, dvs. at den virtuelle maskine for 50 gb tilrådighed. 
        CreateVM $VM_path $VM_name $VM_size #kalder funktionen CreateVM med argumenterne sti, navn og størrelse
    }
    write-host "#----------------------------------------#"
   
}
function CreateVM($VM_path,$VM_name,$VM_size){
    #denne funktion står alt der skal til for at lave en VM
    write-host "#----------Creating VM ... -----------#"
    #Laver bytes om til gigabytes
    [int64]$Vm_size = $Vm_size * 1000000000
    #Har valgt at lave en exception håndtering til oprettelse af vm
    try {
        New-VM -Name $VM_name -path $VM_path -Generation 2   #opretter den nye VM med de arguementer funktionen har fået ind
        Set-VMFirmware -VMName $VM_name -EnableSecureBoot off #Slår secureboot fra, således at man kan installere andre ISO filer end blot windows
        New-VHD -Path $VM_path\$VM_name\$VM_name".vhdx" -SizeBytes  $VM_size -Dynamic #Laver en ny virtuel disk med argumenterne. 
        Add-VMHardDiskDrive -VMName $VM_name -path $VM_path\$VM_name\$VM_name".vhdx" #Mounter den virtuelle harddisk på maskinen
        write-host "#---------- VM has successfully been created -----------#"
        
        $VM_AskISO = read-host "Do you want to add an image file to the new VM? (Yes/no)"
        if($VM_AskISO -eq "Yes"){ # hvis variablen er ligmed "yes", så kører følgende
            $VM_ISO_path = Read-Host "Please specify path to image (.iso) file"
            #har lige lavet en exception handling, da der godt kan se fejl med
            #forkert path, forkert filtype osv. 
            try {
                Add-VMDvdDrive -VMName $VM_name -path $VM_ISO_path #mounter lige en iso fil til dvd-drev, således at den kan bruges til at boote fra.
            }
            catch {
                write-warning $Error[0]
            }
            $VM_start = read-host "Do you want to start your new VM? (Yes/no)"
            #hvis brugeren siger ja til at starte
            if ($VM_start -eq "Yes") {
                Start-VM -Name $VM_name #start vm
                write-host "#---------- VM has successfully been started -----------#"
            } 
        }
        
    }
    catch {
        write-warning $Error[0]
    }
    write-host "You VM has been installed on the following path: $VM_path"
    timeout /t 30
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