<script type="text/javascript" src="./asset/script/js/jquery.js"></script>
<script language="javascript">
	function getDetailedLog(browser_path, type, revision){
		var pageURL = './index.cfm?event=svnSync.getDetailedLog&layout=popUp&browserPath=' + browser_path + '&type=' + type + '&revision=' + revision;
		$("#showDetailedLog_"+revision).hide();
		$("#detailedLog_"+revision).html('<img src="./asset/image/busy.gif" align="absmiddle" />');
		$("#detailedLog_"+revision).show();
		$("#detailedLog_"+revision).load(pageURL,{},function(){$("#hideDetailedLog_"+revision).show();});
	}
	
	function hideDetailedLog(revision){
		$("#detailedLog_"+revision).html('');
		$("#detailedLog_"+revision).hide();
		$("#hideDetailedLog_"+revision).hide();
		$("#showDetailedLog_"+revision).show();
	}
</script>

<h1>Log<cfif not url.revision> History</cfif></h1>
<div align="right"><cfinclude template="diffRevision.cfm" /></div>
<div align="center">
	<table border="0" cellpadding="1" cellspacing="0" class="logTable" width="100%">
	<tr>
		<th>Path:</th>
		<td colspan="6" style="padding-left:5px;">
			<cfoutput>#url.browserPath#</cfoutput>
		</td>
	</tr>
	<tr>
		<th valign="middle">Options</th>
		<th valign="middle">Rev</th>
		<th valign="middle">Message</th>
		<th valign="middle">Date</th>
		<th valign="middle">Time</th>
		<th valign="middle">Author</th>
		<cfif url.type eq 'file'>
			<th valign="middle">Diff</th>
		</cfif>		
	</tr>
	<cfif detailedLog.recordCount>
		<Cfset prevRev = 0 />
		<cfoutput query="detailedLog">
		<tr>
			<td valign="middle" align="center" nowrap="true">
				<cfif url.type eq 'file' and listFindNoCase(application.vars.textFileExt,listLast(url.browserPath,'.'))>
					<a href="javascript:viewFile('#currentJSPath#',#detailedLog.revision#);"><img align="absmiddle" title="View Code" alt="View Code" src="./asset/image/viewcode.gif" border="0" /></a>
				<cfelseif url.type eq 'file' and listFindNoCase(application.vars.imageFileExt,listLast(url.browserPath,'.'))>
					<a href="javascript:viewFile('#currentJSPath#',#detailedLog.revision#);"><img align="absmiddle" title="View Image" alt="View Image" src="./asset/image/viewimage.gif" border="0" /></a>
				<cfelseif url.type eq 'file' and listFindNoCase(application.vars.binaryFileExt,listLast(url.browserPath,'.'))>
					<img src="./asset/image/file.gif" border="0" align="absmiddle" />
				<cfelseif url.type eq 'file'>
					<a href="javascript:viewFile('#currentJSPath#',#detailedLog.revision#);"><img align="absmiddle" src="./asset/image/file.gif" border="0" /></a>
				</cfif>
				
				<cfif url.type eq 'file'>
					<a href="./index.cfm?event=svnSync.getFile&isLog=true&browserPath=#url.browserPath#&revision=#detailedLog.revision#"><img title="Get File" width="16" height="16" src="./asset/image/getfile.gif" border="0" align="absmiddle" alt="Get"></a>
				<cfelse>
					<a href="./index.cfm?event=svnSync.exportZip&isLog=true&browserPath=#url.browserPath#&revision=#detailedLog.revision#"><img title="Export Directory To Zip" width="16" height="16" src="./asset/image/zip.gif" border="0" align="absmiddle" alt="Zip"></a>
				</cfif>
				
				<span id="showDetailedLog_#detailedLog.revision#"><a href="##" onClick="getDetailedLog('#currentJSPath#','#url.type#',#detailedLog.revision#);"><img title="Detailed Log" width="16" height="16" src="./asset/image/detailedLog.gif" border="0" align="absmiddle" alt="Detailed Log"></a></span>
				<span id="hideDetailedLog_#detailedLog.revision#" style="display:none;"><a href="##" onClick="hideDetailedLog(#detailedLog.revision#);"><img title="Hide Detailed Log" width="16" height="16" src="./asset/image/action_stop.gif" border="0" align="absmiddle" alt="Hide Detailed Log"></a></span>
			</td>
			<td valign="middle" align="center">#detailedLog.revision#</td>
			<td valign="middle" align="left">#replace(detailedLog.msg,chr(10),'<br />','all')#</td>	
			<td valign="middle" align="center" width="75">#DateFormat(detailedLog.date,'mm/dd/yyyy')#</td>
			<td valign="middle" align="center" width="75">#TimeFormat(detailedLog.date,'hh:mm:ss tt')#</td>
			<td valign="middle" align="center" style="padding:0 5px;">#detailedLog.author#</td>
			<cfif url.type eq 'file'>
				<td valign="middle" align="center" nowrap="true">
					<a href="##" onClick="viewDiff('#currentJSPath#',-1,#detailedLog.revision#);"><img title="Diff to Local File" width="16" height="16" src="./asset/image/diff_local.gif" border="0" align="absmiddle" alt="Diff - Local"></a>
					<cfif prevRev>
						<a href="##" onClick="viewDiff('#currentJSPath#',0,#detailedLog.revision#);"><img title="Diff to Head Revision" width="16" height="16" src="./asset/image/diff_head.gif" border="0" align="absmiddle" alt="Diff - Head"></a>
					<cfelse>
						<img title="Diff to Head Revision" width="16" height="16" src="./asset/image/diff_head_off.gif" border="0" align="absmiddle" alt="Diff - Head">
					</cfif>
					<Cfset prevRev = detailedLog.revision />
				</td>
			</cfif>
		</tr>
		<tr>
			<td colspan="7">
				<div id="detailedLog_#detailedLog.revision#" style="padding:3px;display:none;"></div>
			</td>
		</tr>
		</cfoutput>
	<cfelse>
		<tr>
			<td colspan="7">No Log Found</td>	
		</tr>
	</cfif>
	</table>
</div>