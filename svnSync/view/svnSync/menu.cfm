<cfset currentJSPath = jsStringFormat(url.browserPath) />
<cfoutput>
<form name="menuForm" action="index.cfm" method="get">
<input type="Hidden" name="event" value="#url.event#" />
<input type="Hidden" name="sortBy" value="#url.sortBy#" />
<input type="Hidden" name="sortDir" value="#url.sortDir#" />
<input type="Hidden" name="browserPath" value="#url.browserPath#" />
<input type="Hidden" name="type" value="#url.type#" />
<table cellpadding="2" cellspacing="2" border="0" class="innerFormTable">
<tr>
	<td align="center" valign="middle" width="20" align="center">
		<a href="##" onClick="menuAction('syncBrowser');">
			<img title="Sync Browser" src="./asset/image/syncBrowser.gif" border="0" align="absmiddle" alt="Sync Browser" />
		</a>
	</td>
	<td align="left" valign="middle" title="Browse"><a href="##" onClick="menuAction('syncBrowser');">Sync Browser</a></td>
	<td align="center" width="20" valign="middle">/</td>
	
	<td align="center" valign="middle" width="20" align="center">
		<a href="##" onClick="menuAction('syncToRevision');">
			<img title="syncToRevision" src="./asset/image/syncToRevision.gif" border="0" name="syncToRevision" align="absmiddle" alt="syncToRevision" />
		</a>
	</td>
	<td align="left" valign="middle" title="Exports The Active Revision to Local File Sytem"><a href="##" onClick="menuAction('syncToRevision');">Sync To Revision</a></td>
	<td align="center" width="20" valign="middle">/</td>
	
	<td align="center" valign="middle" width="20" align="center">
		<a href="##" onClick="viewLog('#currentJSPath#','#url.type#',#url.revision#);">
			<img title="Show Log" src="./asset/image/log.gif" border="0" align="absmiddle" alt="Log" />
		</a>
	</td>
	<td align="left" valign="middle" title="Shows Log"><a href="##" onClick="viewLog('#currentJSPath#','#url.type#',#url.revision#);">Log</a></td>
	<td align="center" width="20" valign="middle">/</td>
	
	<cfif url.revision>
		<td align="center" valign="middle" width="20" align="center">
			<a href="##" onClick="viewLog('#currentJSPath#','#url.type#',0);">
				<img title="Show Log History" src="./asset/image/logHistory.gif" border="0" align="absmiddle" alt="Log History" />
			</a>
		</td>
		<td align="left" valign="middle" title="Show Log History"><a href="##" onClick="viewLog('#currentJSPath#','#url.type#',0);">Log History</a></td>
		<td align="center" width="20" valign="middle">/</td>	
	</cfif>
	
	<td colspan="2" valign="middle">
		<table cellpadding="0" cellspacing="0" border="0" class="innerFormTable" align="right">
		<tr>
			<td align="left" valign="middle" title="Active SVN Revision" nowrap="true">Revision:&nbsp;</td>
			<td width="20" valign="middle"><input type="text" name="revision" value="#url.revision#" size="4" /></td>
			<td align="center" valign="middle" width="20" align="center">
				<a href="##" onClick="if (checkRevision(document.menuForm.revision.value)){document.menuForm.submit();};">
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
<hr />