<div align="center">
	<table border="0" cellpadding="1" cellspacing="0" class="logTable" width="100%">
	<tr>
		<th valign="middle">Rev</th>
		<th valign="middle">Path</th>
		<th valign="middle">Action</th>
	</tr>
	<cfif detailedLog.log.recordCount>
		<cfoutput query="detailedLog.paths">
			<tr>
				<td valign="middle" align="center">#detailedLog.paths.revision#</td>
				<td valign="middle" align="left">#detailedLog.paths.path#</td>
				<td valign="middle" align="center">#detailedLog.paths.action#</td>
			</tr>
		</cfoutput>
	<cfelse>
		<tr>
			<td colspan="3">No Paths Found</td>	
		</tr>
	</cfif>
	</table>
</div>