
function Move-PaketSource {
    [CmdletBinding()]
    [CmdLetTag(("#nuget","#paket"))]
    param (
        [parameter(Mandatory)]
        [int]$Index,
        [parameter(Mandatory)]
        [string]$Target,
        [string]$Path = "."
    )
    
    begin {
        
    }
    
    process {
        $depsFile=(Get-PaketDependenciesPath -Strict)
        if ($depsFile){
            $match=Get-Content $depsFile|Where-Object{$_ -like "source *"}|Select-Object -First ($Index+1)
            $raw=(Get-Content $depsFile -Raw)
            $value=$raw.Replace($match,"source $Target")
            Set-Content  $depsFile $value.Trim()
            
            $lockFile="$($depsFile.DirectoryName)\paket.lock"
            if (Test-Path $lockFile){
                $raw=(Get-Content $lockFile -Raw)
                $match=$match.Replace("source ","")
                $value=$raw.Replace($match,$Target)
                Set-Content  $lockFile $value.Trim()
            }
        }
    }
    
    end {
        
    }
}