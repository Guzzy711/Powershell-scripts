#StopProcess
$Process = "notepad", "calc"
Get-Process -Name $Process -ErrorAction SilentlyContinue |
Stop-Process |
ForEach-Object { $_.Name + ' med i process ID: ' + $_.Id + ' blev stoppet'}
Start-Sleep -s 5
#--------------------------------------------------------
#Variabel2
$a = "this is the beginning"
$b = 22
$c = $a + $b
$c
#$a = "this is a string"
#$c = $a + $b
#$c
#$b = "this is a number"
#$c = $a + $b
$c
[int]$b = 5
$c = $a + $b
$c
$b = "this is a string"
#--------------------------------------------------------
#Variabel1
$proces = Get-Process
$proces | Sort-Object cpu -Descending | Select-Object name, id, cpu
#--------------------------------------------------------
#Switch4
$b = 2,3,4,5,6,7;
switch ($hovedmenu)
{
1 {'Valg nummer 1'}
2 {'Valg nummer 2'}
3 {'VAlg nummer 3'}
4 {'VAlg nummer 4'}
default
{
Write-Host -ForegroundColor red "Forkert valgmulighed"
sleep 2
}
}
#--------------------------------------------------------
#Switch3
$a = Get-Process
Switch ($a)
{
{$_.Handles -in 1..10} {'Meget lille antal Handles.. '+$_.ProcessName;Break}
{$_.Handles -le 100 } {'Mellem stort antal Handles. '+$_.ProcessName;Break}
{$_.Handles -le 1000 } {'Stort antal Handles........ '+$_.ProcessName;Break}
Default {'Meget stort antal Handles.. '+$_.ProcessName;Break}
}
#--------------------------------------------------------
#Switch2
$a = @(1001,1,6,23,77,216,1299)
$b= $true
Switch ($a)
{
{$_ -in 1..10} {if ($b) {'Meget lille tal.. '+$_};$b=$false}
{$_ -le 100 } {if ($b) {'Halv stort tal... ' +$_};$b=$false}
{$_ -le 1000 } {if ($b) {'Ret stort tal.... ' +$_};$b=$true }
Default {if ($b) {'Meget stort tal.. ' +$_};$b=$true }
}
#--------------------------------------------------------
#Switch1
$b = 2,3,4,5,6,7;
Switch ($b)
{
{$_ -in 1,3,5} {'Værdien af $a er: 1 3 5'}
{$_ -in 3,5,7} {'Værdien af $a er: 3 5 7'}
{$_ -in 5,7,9} {'Værdien af $a er: 5 7 9'}
{$_ -in 7,9 } {'Værdien af $a er: 7 9'}
Default {'Værdien af $a er ukendt ' + $_}
}
#--------------------------------------------------------
#ForEach
# Get-Process | ForEach-Object {Write-Host $_.name -foregroundcolor cyan}
# Get-Process > pr.txt
# Get-Content pr.txt
# PowerShell ForEach File Example
Clear-Host
$Path = "C:\Windows\System32\*.dll"
Get-ChildItem $Path | ForEach-Object { Write-Host $_.Name }
#--------------------------------------------------------
#DoWhile
$i = 0
Do {
$i = $i + 1
echo $i
} While ($i -le 10)
#--------------------------------------------------------
#DoUntil
$i = 0
Do {
echo $i
$i = $i + 1
} Until ($i -eq 10)
#--------------------------------------------------------
#While1
$i = 0
While ($i -lt 10)
{
$i++
echo $i
}