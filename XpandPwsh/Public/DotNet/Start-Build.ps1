function Start-Build {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#msbuild"))]
    [alias("sxb")]
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path=(@(Get-ChildItem "*.sln" )+@(Get-ChildItem "*.*proj" )|select-object -first 1).FullName,
        [ArgumentCompleter( {
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
            $p=$fakeBoundParameter.Path
            if (!$p){
                $p=(@(Get-ChildItem "*.sln" )+@(Get-ChildItem "*.*proj" )|select-object -first 1).FullName
            }
            
            ((Read-MSBuildSolutionFile $p).SolutionConfigurations|sort-object ConfigurationName -Unique).ConfigurationName|where-object {$_ -like "*$wordToComplete*"}
        })]
        [string]$Configuration="Debug",
        [ValidateSet("quiet","minimal","normal","detailed","diagnostic")]
        [string]$Verbosity="minimal",
        [switch]$WarnAsError,
        [string]$BinaryLogPath,
        [switch]$NoRestore,
        [int]$MaxCpuCount=([System.Environment]::ProcessorCount),
        [System.IO.FileInfo]$PublishProfile,
        [string[]]$PropertyValue
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        $item=Get-Item $Path
        $project=$item
        if ($item -is [System.IO.DirectoryInfo]){
            Push-Location $item.FullName
            $project=@(Get-ChildItem "*.sln" )+@(Get-ChildItem "*.*proj" )
            Pop-Location
        }
        Invoke-Script{
            $project|ForEach-Object{
                $p=@($_.FullName,"-verbosity:$Verbosity","-maxCpuCount:$MaxCpuCount")
                if (!$NoRestore){
                    $p+="-Restore"
                }
                if ($WarnAsError){
                    $p+="-warnAsError"
                }
                if ($BinaryLogPath){
                    $p+="/bl:$BinaryLogPath"
                }
                if ($Configuration){
                    $p+="/p:Configuration=$Configuration"
                }
                if ($PublishProfile){
                    $p+="/p:DeployOnBuild=true","/p:PublishProfile=$($PublishProfile.Name)"
                }
                if ($PropertyValue){
                    $p+=$PropertyValue|ForEach-Object{"/p:$_"}
                }
                & (Get-MsBuildPath) @p
            }
        }
    }
    end {
        
    }
}