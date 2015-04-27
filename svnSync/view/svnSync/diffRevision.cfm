<cfif url.type eq 'file'>
	<cfoutput>
		<form name="diffRevisionForm" action="" method="get">
		<table cellpadding="2" cellspacing="2" border="0" style="border:1px solid ##ccc">
		<tr>
			<td valign="middle" nowrap="true" align="center" width="50" style="border:1px solid ##ccc;background-color:##EFF6FF;"><strong>DIFF</strong></td>
			<td valign="middle">
				<table cellpadding="0" cellspacing="0" border="0" align="right">
				<tr>
					<td align="left" valign="middle" title="Revision" nowrap="true">Revision:&nbsp;</td>
					<td width="20" valign="middle">
						<select name="revision">
							<option value="0">HEAD</option>
							<cfloop list="#valueList(detailedLog.revision)#" index="iRev">
								<option value="#iRev#">#iRev#</option>
							</cfloop>
						</select>
					</td>
					<td align="left" valign="middle" title="Diff Revision" nowrap="true" style="padding:0px 2px;">Compare To:</td>
					<td width="20" valign="middle">
						<select name="diffRevision">
							<option value="0">HEAD</option>
							<cfloop list="#valueList(detailedLog.revision)#" index="iRev">
								<option value="#iRev#">#iRev#</option>
							</cfloop>
						</select>
					</td>
					<td align="center" valign="middle" width="20" align="center">
						<a href="##" onClick="viewDiff('#currentJSPath#',document.diffRevisionForm.revision.value,document.diffRevisionForm.diffRevision.value);">
							<img title="loadRevision" src="./asset/image/action_go.gif" border="0" name="Load Revision" align="absmiddle" alt="loadRevision" />
						</a>
					</td>
				</tr>
				</table>
			</td>
		</tr>
		</table>
		</form>
	</cfoutput>
</cfif>