# ----------------------------------------------------------------------------------------------------
# Skript na nastavení ExclusionProcess v MS Defender
# Dokumentace: https://dok.vema.cz/#dok.app$f=6;q=263403;leg=cs;redir=2
# ----------------------------------------------------------------------------------------------------

# Programovy adresar s Vema aplikacemi
$vemaProgPath = "C:\Program Files (x86)\Vema\"

# Seznam povolenych podpisovych certifikatu
$allowedSubjects = @(
    'CN="Seyfor, a. s.", O="Seyfor, a. s.", L=Brno, C=CZ', 
    'CN="Vema, a. s.", OU=Software Development, O="Vema, a. s.", L=Brno, C=CZ' 
)

# Rekurzivni iterace programovym adresarem
Get-ChildItem -Path $vemaProgPath -Recurse -Filter *.exe | ForEach-Object {
    try {
        Write-Host $($_.FullName)
        $signature = Get-AuthenticodeSignature $_.FullName
        if ($signature.Status -eq 'Valid' -and $allowedSubjects -contains $signature.SignerCertificate.Subject) {
            Write-Host -ForegroundColor Green " |-> Soubor je podepsany povolenym certifikatem" $signature.SignerCertificate.Subject
            Write-Host -ForegroundColor Green " |-> Pridavam do ExclusionProcess Defenderu"
            Add-MpPreference -ExclusionProcess $_.FullName
        }
    } catch {
        Write-Warning "Chyba pri zpracovani: $($_.FullName) - $_"
    }
}
