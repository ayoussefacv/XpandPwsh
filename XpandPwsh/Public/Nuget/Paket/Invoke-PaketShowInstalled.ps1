
function Invoke-PaketShowInstalled {
    [CmdletBinding()]
    param (
        [parameter(ParameterSetName="Project")]
        [string]$Project,
        [switch]$OnlyDirect,
        [string]$Path="."
    )
    
    begin {
        if ($PSCmdlet.ParameterSetName -eq "Project"){
            $Path =$Project
        }
    }
    
    process {
        (Get-PaketDependenciesPath -strict)|ForEach-Object{
            Write-Host "DependencyFile: $($_.FullName)" -f Blue
            $xtraArgs = @( "--silent");
            if (!$OnlyDirect) {
                $xtraArgs += "--all"
            }
            Push-Location (Get-Item $_).DirectoryName
            if ($Project){
                $pakets=dotnet paket show-installed-packages --project $Project @xtraArgs
            }
            else{
                $pakets=dotnet paket show-installed-packages @xtraArgs
            }
            Pop-Location
            $pakets| ForEach-Object {
                $parts = $_.split(" ")
                [PSCustomObject]@{
                    Group   = $parts[0]
                    Id      = $parts[1]
                    Version = $parts[3]
                }
            }
        }
        
    }
    
    end {
        
    }
}

function Invoke-PaketCommand {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Script
    )
    & $Script
    Approve-LastExitCode
}