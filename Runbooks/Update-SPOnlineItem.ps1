workflow Update-SPOnlineItem
{
	Param(
	  	[Parameter(Mandatory=$true)][String]
		$ListName,
		[Parameter(Mandatory=$true)][int]
		$ListItemId,
		[Parameter(Mandatory=$true)][System.Collections.Hashtable]
		$Values
	)
	#$ListItemId = 22
	#$ListName = "DFS Share Request"
	#$Values = @{"Status" = "Complete"}
	$SPConnection = Get-AutomationConnection -Name 'SharePoint Online Connection'
		
	Write-Verbose "SharePoint Site URL: $($SPConnection.SharePointSiteURL)"
		
    #Get List Fields
    $ListFields = InlineScript
    {
        Import-Module SharePointSDK -ErrorAction "stop"
        $ListFields = Get-SPListFields -SPConnection $USING:SPConnection -ListName $USING:ListName -verbose  -ErrorAction "stop"
        ,$ListFields
    }  -ErrorAction "stop"
		
	$UpdateDetails = @{}
	foreach ($key in $Values.Keys)
	{
		$Field = ($ListFields | Where-Object {$_.Title -ieq $key -and $_.ReadOnlyField -eq $false}).InternalName
		if (!$Field) { throw "'$key' field/column not found in SharePoint List $ListName"}
		$UpdateDetails += @{ $Field = $Values[$key]}
	}
	$UpdateDetails
	
	Write-Verbose "`$UpdateDetails = $UpdateDetails"
	#Update a list item
    $UpdateListItem = InlineScript
    {
        Import-Module SharePointSDK  -ErrorAction "stop"  
        $UpdateListItem = Update-SPListItem -ListFieldsValues $USING:UpdateDetails -ListItemID $USING:ListItemID -ListName $USING:ListName -SPConnection $USING:SPConnection  -ErrorAction "stop"
        $UpdateListItem
    }  -ErrorAction "stop"
    Write-Output "List Item (ID: $ListItemId) updated: $UpdateListItem."
}