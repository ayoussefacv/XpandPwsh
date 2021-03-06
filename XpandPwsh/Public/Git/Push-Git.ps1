function Push-Git {
    [CmdletBinding()]
    [CmdLetTag("#git")]
    param (
        [parameter(ParameterSetName = "AddAll")]
        [switch]$AddAll,
        [parameter(ParameterSetName = "AddAll")]
        [string]$Message,
        [string]$Branch,
        [string]$Remote="origin",
        [string]$Username,
        [string]$UserMail,
        [switch]$Force
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        Invoke-Script{
            git config core.autocrlf true
            if ($username){
                git config user.name $userName
            }
            if ($UserMail){
                git config user.email $userMail
            }
            if ($AddAll) {
                git add -A
                if ($message) {
                    git commit -m $message
                }
                else {
                    git commit --amend  --no-edit
                }
            }
        }
        Invoke-Script{
            $a=@("-q")
            if ($Force){
                $a+="-f"
            }
            $a+=$Remote
            if ($Branch){
                $a+=$Branch
            }
            git push @a
        }
    }
    
    end {
        
    }
}