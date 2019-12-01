function Remove-AzBuild {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="id")]
        [int]$Id,
        [parameter(ParameterSetName="switch")]
        [switch]$InProgress,
        [string]$Project=$env:AzProject,
        [string]$Organization=$env:AzOrganization,
        [string]$Token=$env:AzDevopsToken
    )
    
    begin {
        $cred=@{
            Project=$Project
            Organization=$Organization
            Token=$Token
        }        
    }
    
    process {
        if($InProgress){
            Get-AzBuilds -Status inProgress|Remove-AzBuild
        }
        else{
            Invoke-AzureRestMethod "build/builds/$Id" @cred -Method Delete
        }
    }
    
    end {
        
    }
}