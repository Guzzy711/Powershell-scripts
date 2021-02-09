#Brugerinput
[int16]$pw_length = read-host "Password length"
$complexity = read-host "Password Complexity (1 = easy, 2 = Medium, 3 = Complex)"

$pw = "" #Definere en tom string til opbevaring af password karaktere
#Så længe at variablen i er mindre eller ligmed password længden, så kører dette
#loop 
for($i=1;$i -le $pw_length;$i++){
    switch ($complexity) {
        #Vælger at lave en funktion der tager højde for compleksiteten af
        #adgangskoden. Det gøres ved at udvide ascii intervallet til at være
        #højere, dvs. at der kommer flere special tegn med. 
        # Default er sat til at være easy
        #Ascii tabellen der er gået udfra kan findes her: https://www.asciitable.com/index/asciifull.gif
        1 { 
            #Genererer et random tal udfra get-random objektet, med en minimumsværdi på
            #65 og maks på 90. Den typecaster jeg så til en char, da vær karakter har en
            #ASCII numerisk værdi. f.eks. er 65 svarende til A
            [char]$rd_number = Get-Random -Minimum 65 -Maximum 90
         }
        2 {
            [char]$rd_number = Get-Random -Minimum 65 -Maximum 126
        }
        3 {
            [char]$rd_number = Get-Random -Minimum 33 -Maximum 126
        }
        Default {
            [char]$rd_number = Get-Random -Minimum 65 -Maximum 90
        }
    }
    #Tilføjer det nye ascii karakter til password-string. 
    $pw += $rd_number
}
echo "Your new password is: " $pw