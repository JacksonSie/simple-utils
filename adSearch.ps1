echo "./this/script empNo1 empNo2 empNo3 ..."


ActDirEntry = "LDAP://DC=cropad,DC=intranet,DC=local"

foreach ($arg in $args){
	$strFilter = "(sAMAccountName=" +$arg + ")"
	$objDomain = New-Object System.DirectoryServices.DirectoryEntry(ActDirEntry)

	$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
	$objSearcher.SearchRoot = $objDomain
	$objSearcher.PageSize = 0
	$objSearcher.Filter = $strFilter
	$objSearcher.SearchScope = "Subtree"

	#$colProplist = "cn" , "description" , "distinguishedName" , "mail"
	$colProplist = "description"
	foreach ($i in $colPropList){$objSearcher.PropertiesToLoad.Add($i) | out-null}
	#$colResults = $objSearcher.findall()
	$colResults = $objSearcher.findone()
	
	#$colResults |  Get-Member
	foreach ($objResult in $colResults){
		$objItem = $objResult.Properties
		#echo $objItem.PropertyNames
		$name = [regex]::Match($objItem.adspath,'CN=(.*?),').groups[1].value
		$ID = $arg
		$dep = [regex]::Match($objItem.adspath,'OU=(.*?),').groups[1].value
		$isOnJob = $objItem.description
		echo "$ID	$dep	$name	$isOnJob"
	}
}
