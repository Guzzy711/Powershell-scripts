
#Gemmer alle vokaler som et array, har valgt at gøre disse variabler globale,
#således at de kan tilgåes i senere opgave. 
$vokal = @('a','e','i','o','u','y','æ','ø','å')
#Gemmer alle konsonanter som et array
$kons = @('b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'z')


function CheckLetter(){
    #gemmer userinput i variablen inputs, der automatisk gemmer det som en string
    $inputs = read-host "Indtast et bogstav"
    #Hvis input variablen findes i vokal-array, eller i kons arrayet, så:
    if ($inputs -in $vokal -OR $inputs -in $kons){
        #Hvis inputtet findes i vokal array, må det være en vokal
        if($inputs -in $vokal){
            write-host "Dette er en vokal"
        }
        #ellers må det være en konsonant
        else{
            write-host "Dette er en konsonant"
        }
      
    }
    else{
        write-host "Det indtastede er ikke et bogstav"
    }

}
Checkletter

function SwitchStatement(){
    #Definere et array 
     $options = @("Æble", "Pære", "Banan", "Melon", "Tomat", "Vindrue", "Mango", "Blomme", "Appelsin", "Citron")
     #har en variable jeg kører mit loop udfra
     $c = $false
     while($c -eq $false){ #så længe at denne variable er falsk, så kører loopet
         
        switch(read-host "Vælg tal fra 0-9"){ #switch på brugerinput
            0 { #hvis brugeren indtaster 0, så skriv hvad de har valgt og sæt variablen til true, som gør at den går ud af loopet, da udsagnet ikke længere er sandt. 
                write-host "Du har valgt:" $options[0] 
                $c = $true
            }
            1 {
                write-host "Du har valgt:" $options[1]
                $c = $true
            }
            2 {
                write-host "Du har valgt:" $options[2]
                $c = $true
            }
            3 {
                write-host "Du har valgt:" $options[4]
                $c = $true
            }
            4 {
                write-host "Du har valgt:" $options[4]
                $c = $true
            }
            5 {
                write-host "Du har valgt:" $options[5]
                $c = $true
            }
            6 {
                write-host "Du har valgt:" $options[6]
                $c = $true
            }
            7 {
                write-host "Du har valgt:" $options[7]
                $c = $true
            }
            8 {
                write-host "Du har valgt:" $options[8]
                $c = $true
            }
            9 {
                write-host "Du har valgt:" $options[9]
                $c = $true
            }
        }
     }
}
SwitchStatement

function countFile(){
    $path = read-host "Vælg sti til fil"
    #Læser filen der har  den sti som brugeren taster
    $file = Get-Content $path 
    #Tager den fil, og kopirer karaktererne op i et Char-Array
    $split_array = $file.TocharArray()
    #for hver karakter i dette array
    foreach($c in $split_array){
         #Hvis karakteren findes i vokal-array, eller i kons arrayet, så:
        if ($c -in $vokal -OR $c -in $kons){
            #Hvis karakteren findes i vokal array, må det være en vokal
            if($c -in $vokal){
                write-host "Dette er en vokal"
            }
            #ellers må det være en konsonant
            else{
                write-host "Dette er en konsonant"
            }
        
        }
    }
   

}
countFile
