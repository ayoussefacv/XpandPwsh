function Get-XpandVersion { 
    [CmdletBinding()]
    param(
        $XpandPath,
        [switch]$Latest,
        [switch]$Release,
        [switch]$Lab,
        [switch]$Next,
        [string]$Module="eXpand"
    )
    if ($Next) {
        $official = Get-XpandVersion -Release -Module $Module
        if (!$official){
            Write-Verbose "Release not found"
            return
        }
        Write-Verbose "Release=$official"
        $labVersion = Get-XpandVersion -Lab -Module $Module
        Write-Verbose "lab=$labVersion"
        $revision = 0
        $baseVersion=Get-DevExpressVersion -Latest
        if ($Module -ne "eXpand"){
            $baseVersion=$official
        }
        Write-Verbose "baseVersion=$baseVersion"
        $build="$($baseVersion.Build)00"
        if (($official.Build -like "$($baseVersion.build)*")){
            if ($official.Build -eq $labVersion.Build) {
                $revision = $labVersion.Revision + 1
                if ($labVersion.Revision -eq -1) {
                    $revision = 1
                }
                $build=$official.Build
            }
            elseif ($official.Build -gt $labVersion.Build) {
                $build=$official.Build
                $revision=1
            }
        }
        else{
            $revision = $labVersion.Revision + 1
            if ($labVersion.Revision -eq -1) {
                $revision = 1
            }
        }
        return New-Object System.Version($baseVersion.Major, $baseVersion.Minor, $build, $revision)
    }
    if ($XpandPath) {
        $assemblyIndoName="AssemblyInfo"
        $pattern='AssemblyVersion\("([^"]*)'
        if ($Module -eq "eXpand"){
            $assemblyInfoPath="Xpand\Xpand.Utils"
            $assemblyIndoName="XpandAssemblyInfo"
            $pattern='public const string Version = \"([^\"]*)'
        }
        $assemblyInfo = "$XpandPath\$assemblyInfoPath\Properties\$assemblyIndoName.cs"
        
        $matches = Get-Content $assemblyInfo -ErrorAction Stop | Select-String $pattern
        if ($matches) {
            return New-Object System.Version($matches[0].Matches.Groups[1].Value)
        }
        else {
            Write-Error "Version info not found in $assemblyInfo"
        }
        return
    }
    if ($Latest) {
        $official = Get-XpandVersion -Release -Module $Module
        $labVersion = Get-XpandVersion -Lab -Module $Module
        if ($labVersion -gt $official) {
            $labVersion
        }
        else {
            $official
        }
        return
    }
    if ($Lab) {
        return (& $(Get-NugetPath) list $Module -Source (Get-PackageFeed -Xpand)|ConvertTo-PackageObject -LatestVersion|Sort-Object -Property Version -Descending |Select-Object -First 1).Version
    }
    if ($Release) {
        return (& $(Get-NugetPath) list $Module -Source (Get-PackageFeed -Nuget)|Where-Object{$_ -like "$Module*"}|ConvertTo-PackageObject|Sort-Object -Property Version -Descending |Select-Object -First 1).Version
    }
}