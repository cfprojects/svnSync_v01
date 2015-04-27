<style>
.historyTable {
	border-collapse:collapse;
	border:1px solid #CCCCCC;
	margin: 5px 0px 5px 0px; 
	font-family: Arial, Helvetica, sans-serif;
}

.historyTable th{
	font-size:10px;
	color:#666666;
	font-weight:normal;
	border:1px solid #CCCCCC;
	background-color: #EEEEEE;
}

.historyTable td{
	font-size:10px;
	border:1px solid #CCCCCC;
	padding:2px;
}

a, a:visited, a:link, a:active
{
	font-size:10px;
	text-decoration:none;
}

a:hover
{
	text-decoration:underline;
}
</style>

<div align="center" id="syncResults" style="font-family:Arial;font-size:12px;">
	<br />
	<cfif isDefined('fileList')>
		<table border="0" cellpadding="1" cellspacing="0" class="historyTable" align="center">
		<tr>
			<th valign="middle">Directory</th>
			<th valign="middle">File</th>
			<th valign="middle" width="35">Rev</th>
			<th valign="middle">Size</th>
			<th valign="middle" width="130">Date</th>
		</tr>
		<cfif fileList.recordCount>
			<cfoutput query="fileList">
			<tr>
				<td valign="middle" style="padding:0px 5px">&nbsp;#fileList.directory#</td>
				<td valign="middle" style="padding:0px 5px">&nbsp;#fileList.name#</td>
				<td valign="middle" align="center" style="padding:0px 5px">#fileList.revision#</td>
				<td valign="middle" align="center" style="padding:0px 5px">#fileList.size#</td>
				<td valign="middle" align="center" style="padding:0px 5px" title="local | #DateFormat(fileList.localdatelastmodified,'mm/dd/yyyy')# #TimeFormat(fileList.localdatelastmodified,'hh:mm:ss tt')#">#DateFormat(fileList.datelastmodified,'mm/dd/yyyy')# #TimeFormat(fileList.datelastmodified,'hh:mm:ss tt')#</td>
			</tr>
			</cfoutput>
		<cfelse>
			<tr>
				<td valign="middle" align="center">No Files Found</td>
			</tr>
		</cfif>
		</table>
	<cfelseif isDefined('svnLog.paths')>
		<table border="0" cellpadding="1" cellspacing="0" class="historyTable" width="95%">
		<tr>
			<th>Updated On</th>
			<td colspan="2"><cfoutput>#dateFormat(svnLog.log.date,'mm/dd/yy')#</cfoutput></td>
		</tr>
		<tr>
			<th>Updated By</th>
			<td colspan="2"><cfoutput>#svnLog.log.author#</cfoutput></td>
		</tr>
		<tr>
			<th>Message</th>
			<td colspan="2"><cfoutput>#svnLog.log.msg#</cfoutput></td>
		</tr>
		<tr>
			<th valign="middle">Action</th>
			<th valign="middle">Path</th>
			<th valign="middle">Rev</th>
		</tr>
		<cfif svnLog.paths.recordCount>
			<cfoutput query="svnLog.paths">
			<tr>
				<td valign="middle" align="center">&nbsp;#svnLog.paths.action#</td>
				<td valign="middle">&nbsp;#svnLog.paths.path#</td>
				<td valign="middle" align="center">#svnLog.paths.revision#</td>
			</tr>
			</cfoutput>
		<cfelse>
			<tr>
				<td valign="middle" align="center">No Files Found</td>
			</tr>
		</cfif>
		</table>
	</cfif>
</div>