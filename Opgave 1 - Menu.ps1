function menu() 
{
    do
    {
        Clear-Host
        Write-Host "
            #----------------------------------------------------------#
            #                 Enkle cmdlet opgaver                     #
            #                                                          #
            #                                                          #
            #   1. Serienummeret på disken på maskinen                 #
            #   2. De ti største/længste filer på maskinen             #
            #   3. Find de ti ældste dll filer på maskinen             #
            #                                                          #
            #   5. HotFix’es på maskinen sorteret efter Description    #
            #   6. Ledig fysisk hukommelse                             #
            #   7. Ledig virtuel hukommelse                            #
            #                                                          #
            #   8. PowerShell versionen                                #
            #                                                          #
            #   0. Slut                                                #
            #                                                          #
            #                                                          #
            #----------------------------------------------------------#
            "
        $hovedmenu = read-host "Indtast valgmulighed"

        switch ($hovedmenu)
        {
            1 {SerieNummer}
            2 {TiStoerste}
            3 {Aeldste}

            5 {HotFixDesc}
            6 {LedigFysiskHukommelse}
            7 {LedigVirtuelHukommelse}

            8 {PSVersion}

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

function SerieNummer
{
    
    # Der findes flere mulige løsninger, både med hensyn til cmdlet
    # og med hensyn til hvilket 'nummer' der menes.
    # Get-WmiObject er en mulig cmdlet. 

    Write-Host 'SerieNummer - Tast Enter' -NoNewline
    #Henter seriel number på den fysiske harddisk - her bruger jeg format list,
    #som står for at udtrække KUN serialnumber. Der findes også andre options,
    #f.eks. Capacity
    #Det gøres ved at udskrive objektet win32_PhysicalMedia, som kan findes
    #defineret som klasse her:
    #https://docs.microsoft.com/en-us/previous-versions/windows/desktop/cimwin32a/win32-physicalmedia
    #hvor de andre properties kan findes
    Get-WMIObject -class win32_PhysicalMedia -filter "" | Format-List SerialNumber
    timeout /T 30
}


function TiStoerste
{
    # Denne opgave bør løses i en række step. Bemærk, at alle filer 
    # på disken skal undersøges så det tager lang tid, så start i en 
    # velvalgt folder, og vent til alt andet er på plads inden 
    # søgningen udvides til alle filer på disken.
    # Step 1: find alle filer på disken (aktuel folder). Get-ChildItem x
    # Step 2: Pipeline videre og sorter objekterne. Sort-Object x 
    # Step 3: Pipeline videre og udvælg de 10 første. Select-Object x
    # Step 4: Pipeline videre og afslut med at formatere i tabelform.
    # Format-Table x
    # Step 5: Tilføj filer i undermapper. Get-ChildItem parameter x
    # Step 6: Vælg c:\ som start-path. Get-ChildItem parameter / Husk Ctrl-C
    # ;-) 
    # Step 7: Der kan komme røde fejltekst pga. manglende adgang. -ErrorAction
    
    Write-Host 'Søger efter de ti største filer ...' -NoNewline
    #Definere en variable som angiver den sti jeg vil have
    $path = "C:\"
    #Benytter cmdlet Get-chilitem, hvorefter jeg laver 3 pipelines, hhv.
    # Har sat -recurse som søger igennem alt der er adgang til, for at der ikke
    # vises fejlmeddelser hvergang der ikke er adgang, så benytes -ErrorAction
    # SilentlyContinue, som sørger for, at hvis der fremkommer fejl, går den
    # blot videre. 
    #Sort-object, select-object og format-table
    #Sort-object tager jeg og sorterer efter længden faldende, dvs. at en
    #største fil vil blive vist øverst.
    #Select-object benytter jeg til at vælge, at det kun er de ti første
    #filer der skal vises
    #Format-table benytter jeg for formatering af det output der gives. Her
    #vælger jeg kun at vise Mode, og navnet på filen. 
    Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Sort-Object -Property Length -descending | Select-Object -first 10 | Format-Table Mode, Name 
    #har valgt at lave en exception handling, for at sikre at der er
    #fejlhåndtering, hvis filen allerede findes
    try {
        #benytter cmdlet new-item til at lave en ny fil. Herunder specificerer
        #jeg lokation, navn og typen på filen. 
        #Siger også at processen skal stoppe hvis der sker en fejl. 
        New-Item -Path "$path" -Name test.txt -itemType File -ErrorAction Stop
    }  
    catch {
        #Benytter $error vriablen som indeholder et array af fejl som er
        #opstået.
        # Ved at benytte index 0, får jeg den nyeste fejl.
        Write-Warning $Error[0]
    }
    timeout /T 30
}

function Aeldste
{
    # Repetiton i forhold til TiStoerste
    #Write-Host 'Aeldste - Tast enter' -NoNewline
    # sætter $path variablen igen
    $path = "C:\"
    #benytter get-childitem igen, hvor jeg sorterer efter CreationTime, og igen
    #vælger jeg de ti første objekter, 
    #ved formatering har jeg tilføjet at den også skal vise CreationTime for at
    #give visuel overblik over hvornår de er lavet.
    Get-ChildItem $path *.dll -Recurse -ErrorAction SilentlyContinue | Sort-Object -Property CreationTime | Select-Object -first 10 | Format-Table Mode, Name, CreationTime
    timeout /T 30
}

function HotFixDesc
{
    # Get-HotFix
    Write-Host 'HotFixDesc - Tast enter' -NoNewline
    get-hotfix | Sort-object Description | format-table HotfixID,Description,InstalledOn
    timeout /T 30
}

function LedigFysiskHukommelse
{
    Write-Host 'LedigFysiskHukommelse - Tast enter' -NoNewline
    #benytter cminstance cmdlet for at tilgå det fysiske hukommelse, hvoraf der
    #bliver formateret på navnet og størrelsen. 
    Get-CimInstance -class cim_physicalmemory | format-table Name, Capacity
    timeout /T 30
}

function LedigVirtuelHukommelse
{
    #har skrevet en regularexpression der går ind og leder i propertien "tag",
    #og ser om der er noget der matcher Virtual, og hvis der er skal den vælges.
    #Der kan umiddelbart ikke finde en CIM-funtion der kan finde virtuel hukommelse
    Write-Host 'LedigVirtuelHukommelse - Tast enter' -NoNewline
    Get-CimInstance -class cim_physicalmemory | Where-Object {$_.Tag -Match "Virtual*"} | format-table Name, Capacity
    timeout /T 30
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