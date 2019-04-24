function Get-OVGDAppliance {
    <#
        .SYNOPSIS
            Retrieves appliances connected to the Global Dashboard instance
        .DESCRIPTION
            This function will retrieve the appliances connected to the specified Global Dashboard instance
        .NOTES
            Info
            Author : Rudi Martinsen / Intility AS
            Date : 25/03-2019
            Version : 0.3.0
            Revised : 24/04-2019
            Changelog:
            0.3.0 -- Added support for querying, changed text when result is bigger than count
            0.2.2 -- Fixed minor bug in help text, added link
            0.2.1 -- Added help text
            0.2.0 -- Added count param
        .LINK
            https://github.com/rumart/GlobalDashboardPS
        .LINK
            https://developer.hpe.com/blog/accessing-the-hpe-oneview-global-dashboard-api
        .LINK
            https://rudimartinsen.com/2019/04/23/hpe-oneview-global-dashboard-powershell-module/
        .PARAMETER Server
            The Global Dashboard to retrieve appliances from
        .PARAMETER Entity
            The appliance to retrieve
        .PARAMETER ApplianceName
            Filter on ApplianceName of Appliance to retrieve. Note the search is case-sensitive and searches for an exact match
        .PARAMETER ApplianceLocation
            Filter on ApplianceLocation of Appliance to retrieve. Note the search is case-sensitive and searches for an exact match
        .PARAMETER Status
            Filter on Status of Appliance to retrieve. Note the search is case-sensitive and searches for an exact match
        .PARAMETER State
            Filter on State of Appliance to retrieve. Note the search is case-sensitive and searches for an exact match
        .PARAMETER UserQuery
            Query string used for full text search
        .PARAMETER Count
            The count of appliances to retrieve, defaults to 25
        .EXAMPLE
            PS C:\> Get-OVGDAppliance

            Retrieves all OneView appliances connected to the Global Dashboard instance
        .EXAMPLE
            PS C:\> Get-OVGDAppliance -Entity oneview-001

            Retrieves the specific OneView appliances with the name "oneview-001"
    #>
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(ParameterSetName="Default")]
        [Parameter(ParameterSetName="Id")]
        [Parameter(ParameterSetName="Query")]
        $Server,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [Parameter(ParameterSetName="Id")]
        [alias("Appliance")]
        $Entity,
        [Parameter(ParameterSetName="Query")]
        $ApplianceName,
        [Parameter(ParameterSetName="Query")]
        $ApplianceLocation,
        [Parameter(ParameterSetName="Query")]
        [ValidateSet("OK","Warning","Critical")]
        $Status,
        [Parameter(ParameterSetName="Query")]
        [ValidateSet("Online","Offline","Failed","Unknown")]
        $State,
        [Parameter(ParameterSetName="Query")]
        $UserQuery,
        [Parameter(ParameterSetName="Default")]
        [Parameter(ParameterSetName="Id")]
        [Parameter(ParameterSetName="Query")]
        $Count = 25
    )
    BEGIN {
        $ResourceType = "appliances"

    }
    PROCESS {
        $Resource = BuildPath -Resource $ResourceType -Entity $Entity
        $Query = "count=$Count"
        $searchFilters = @()
        $txtSearchFilters = @()

        if($ApplianceName){
            $searchFilters += 'applianceName EQ "' + $ApplianceName + '"'
        }

        if($ApplianceLocation){
            $searchFilters += 'applianceLocation EQ "' + $ApplianceLocation + '"'
        }

        if($Status){
            $searchFilters += 'status EQ "' + $Status + '"'
        }

        if($State){
            $searchFilters += 'state EQ "' + $State + '"'
        }

        if($UserQuery){
            $txtSearchFilters += "$UserQuery"
        }

        if($searchFilters){
            $filterQry = $searchFilters -join " AND "
            $Query += '&query="' + $filterQry + '"'
        }

        if($txtSearchFilters){
            $filterQry = $txtSearchFilters -join " AND "
            $Query += '&userQuery="' + $filterQry + '"'
        }

        $result = Invoke-OVGDRequest -Resource $Resource -Query $Query

        Write-Verbose "Got a total of $($result.total) result(s)"
        if ($result.Count -lt $result.Total ) {
            Write-Warning "The result has been paged. Total number of results is: $($result.total)"
        }

        $output = Add-OVGDTypeName -TypeName "GlobalDashboardPS.OVGDAppliance" -Object $result.members
        return $output

    }
    END {

    }

}