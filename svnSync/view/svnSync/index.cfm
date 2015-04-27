<cfoutput>
	<form name="browserForm" action="index.cfm" method="get">
	<input type="hidden" name="event" value="#url.event#" />
	<input type="hidden" name="sortBy" value="#url.sortBy#" />
	<input type="hidden" name="sortDir" value="#url.sortDir#" />
	<input type="hidden" name="revision" value="#url.revision#" size="5" />
	<table cellpadding="0" cellspacing="0" border="0" class="browserTable" id="browserTable" width="100%">
	<tr>
		<td colspan="2" align="center" bgcolor="##EEEEEE">
			local
		</td>
		<td colspan="6" style="padding:2px 5px 2px 5px;" bgcolor="##EEEEEE" align="right">
			#fileList.localPath#
		</td>
	</tr>
	<tr>
		<td colspan="2" align="center" bgcolor="##EEEEEE">
			svn
		</td>
		<td colspan="6" style="padding:2px 5px 2px 5px;" bgcolor="##EEEEEE" align="right">
			#fileList.svnURL#
		</td>
	</tr>
	<tr>
		<td colspan="2" align="center" valign="middle"><a href="##" onClick="syncSelected();"><img title="Sync Selected Files" src="./asset/image/syncSelected.gif" border="0" name="syncFiles" align="absmiddle" alt="Sync" /></a></td>
		<td colspan="6" align="right" style="padding:2px">
			<table cellpadding="0" cellspacing="0" border="0" class="innerFormTable" align="right" width="90%">
			<tr>
				<td style="font-size:10px;" width="25" align="right">Location:</td>
				<td><input type="text" name="browserPath" value="#url.browserPath#" class="formField" style="width:100%;" /></td>
				<td align="center" valign="middle" width="20" align="center">
					<a href="##" onClick="document.browserForm.submit();">
						<img title="loadRevision" src="./asset/image/action_go.gif" border="0" name="Load Revision" align="absmiddle" alt="loadRevision" />
					</a>
				</td>
			</tr>
			</table>
		</td>
	</tr>
	<tr>
		<th valign="middle" width="20">
			<a href="##" onClick="selectAll();"><img id="selectAllImg" title="Select\Deselect All" src="./asset/image/bullet_add.gif" border="0" align="absmiddle" alt="Select\Deleselect All" /></a>
		</th>
		<th valign="middle" width="35">
			<table align="center" cellpadding="0" cellspacing="0" class="innerFormTable" border="0">
				<tr>
					<td width="15" align="center">
						<cfif url.sortBy eq 'type,svn_name' and url.sortDir eq 'asc'>
							<img title="Sort" src="./asset/image/bullet_arrow_up.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						<cfelseif url.sortBy eq 'type,svn_name' and url.sortDir eq 'desc'>
							<img title="Sort" src="./asset/image/bullet_arrow_down.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						</cfif>
					</td>
					<td><a href="##" onClick="sortSearch('type,svn_name');">-</a></td>
					<td width="15" align="center">
						<cfif url.sortBy eq 'type,svn_name' and url.sortDir eq 'asc'>
							<img title="Sort" src="./asset/image/bullet_arrow_up.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						<cfelseif url.sortBy eq 'type,svn_name' and url.sortDir eq 'desc'>
							<img title="Sort" src="./asset/image/bullet_arrow_down.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						</cfif>
					</td>
				</tr>
			</table>
		</th>
		<th valign="middle">
			<table align="center" cellpadding="0" cellspacing="0" class="innerFormTable" border="0">
				<tr>
					<td width="15" align="center">
						<cfif url.sortBy eq 'svn_name' and url.sortDir eq 'asc'>
							<img title="Sort" src="./asset/image/bullet_arrow_up.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						<cfelseif url.sortBy eq 'svn_name' and url.sortDir eq 'desc'>
							<img title="Sort" src="./asset/image/bullet_arrow_down.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						</cfif>
					</td>
					<td><a href="##" onClick="sortSearch('svn_name');">Name</a></td>
					<td width="15" align="center">
						<cfif url.sortBy eq 'svn_name' and url.sortDir eq 'asc'>
							<img title="Sort" src="./asset/image/bullet_arrow_up.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						<cfelseif url.sortBy eq 'svn_name' and url.sortDir eq 'desc'>
							<img title="Sort" src="./asset/image/bullet_arrow_down.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						</cfif>
					</td>
				</tr>
			</table>
		</th>
		<th valign="middle" width="125">	
			<table align="center" cellpadding="0" cellspacing="0" class="innerFormTable" border="0">
				<tr>
					<td width="15" align="center">
						<cfif url.sortBy eq 'svn_datetime' and url.sortDir eq 'asc'>
							<img title="Sort" src="./asset/image/bullet_arrow_up.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						<cfelseif url.sortBy eq 'svn_datetime' and url.sortDir eq 'desc'>
							<img title="Sort" src="./asset/image/bullet_arrow_down.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						</cfif>
					</td>
					<td><a href="##" onClick="sortSearch('svn_datetime');">Date</a></td>
					<td width="15" align="center">
						<cfif url.sortBy eq 'svn_datetime' and url.sortDir eq 'asc'>
							<img title="Sort" src="./asset/image/bullet_arrow_up.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						<cfelseif url.sortBy eq 'svn_datetime' and url.sortDir eq 'desc'>
							<img title="Sort" src="./asset/image/bullet_arrow_down.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						</cfif>
					</td>
				</tr>
			</table>
		</th>
		<th valign="middle" width="50">
			<table align="center" cellpadding="0" cellspacing="0" class="innerFormTable" border="0">
				<tr>
					<td width="15" align="center">
						<cfif url.sortBy eq 'revision' and url.sortDir eq 'asc'>
							<img title="Sort" src="./asset/image/bullet_arrow_up.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						<cfelseif url.sortBy eq 'revision' and url.sortDir eq 'desc'>
							<img title="Sort" src="./asset/image/bullet_arrow_down.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						</cfif>
					</td>
					<td><a href="##" onClick="sortSearch('revision');">Rev</a></td>
					<td width="15" align="center">
						<cfif url.sortBy eq 'revision' and url.sortDir eq 'asc'>
							<img title="Sort" src="./asset/image/bullet_arrow_up.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						<cfelseif url.sortBy eq 'revision' and url.sortDir eq 'desc'>
							<img title="Sort" src="./asset/image/bullet_arrow_down.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						</cfif>
					</td>
				</tr>
			</table>
		</th>
		<th valign="middle" width="50">
			<table align="center" cellpadding="0" cellspacing="0" class="innerFormTable" border="0">
				<tr>
					<td width="15" align="center">
						<cfif url.sortBy eq 'status' and url.sortDir eq 'asc'>
							<img title="Sort" src="./asset/image/bullet_arrow_up.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						<cfelseif url.sortBy eq 'status' and url.sortDir eq 'desc'>
							<img title="Sort" src="./asset/image/bullet_arrow_down.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						</cfif>
					</td>
					<td><a href="##" onClick="sortSearch('status');">Status</a></td>
					<td width="15" align="center">
						<cfif url.sortBy eq 'status' and url.sortDir eq 'asc'>
							<img title="Sort" src="./asset/image/bullet_arrow_up.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						<cfelseif url.sortBy eq 'status' and url.sortDir eq 'desc'>
							<img title="Sort" src="./asset/image/bullet_arrow_down.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						</cfif>
					</td>
				</tr>
			</table>
		</th>
		<th valign="middle" width="50">
			<table align="center" cellpadding="0" cellspacing="0" class="innerFormTable" border="0">
				<tr>
					<td width="15" align="center">
						<cfif url.sortBy eq 'svn_size' and url.sortDir eq 'asc'>
							<img title="Sort" src="./asset/image/bullet_arrow_up.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						<cfelseif url.sortBy eq 'svn_size' and url.sortDir eq 'desc'>
							<img title="Sort" src="./asset/image/bullet_arrow_down.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						</cfif>
					</td>
					<td><a href="##" onClick="sortSearch('svn_size');">Size</a></td>
					<td width="15" align="center">
						<cfif url.sortBy eq 'svn_size' and url.sortDir eq 'asc'>
							<img title="Sort" src="./asset/image/bullet_arrow_up.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						<cfelseif url.sortBy eq 'svn_size' and url.sortDir eq 'desc'>
							<img title="Sort" src="./asset/image/bullet_arrow_down.gif" border="0" align="absmiddle" alt="Sort" width="9" height="7" />
						</cfif>
					</td>
				</tr>
			</table>
		</th>
		<th valign="middle" width="110">									
			Options
		</th>
	</tr>
		<cfif listLen(url.browserPath,'/')>
			<tr class="row2" id='rowRoot' onmouseover="highlightRow('rowRoot','on');" onmouseout="highlightRow('rowRoot','off');">
				<td valign="middle" align="center" bgcolor="##EEEEEE"></td>
				<td valign="middle" align="center"><img src="./asset/image/folder.gif" border="0" /></td>
				<td valign="middle" style="padding-left:5px;"><a href="##" onClick="changePath('#jsStringFormat('/')#');">. (root)</a></td>
				<td valign="middle" align="center" colspan="5"></td>			
			</tr>
		</cfif>
		<cfif listLen(parentPath,'/')>
			<tr class="row2" id='rowParent' onmouseover="highlightRow('rowParent','on');" onmouseout="highlightRow('rowParent','off');">
				<td valign="middle" align="center" bgcolor="##EEEEEE"></td>
				<td valign="middle" align="center"><img src="./asset/image/folder.gif" border="0" /></td>
				<td valign="middle" style="padding-left:5px;"><a href="##" onClick="changePath('#jsStringFormat(parentPath)#');">.. (parent)</a></td>
				<td valign="middle" align="center" colspan="5"></td>				
			</tr>
		</cfif>
		<cfif isDefined('fileList.results.recordCount') and fileList.results.recordCount>
			<cfloop query="fileList.results">
				<cfset currentPath = fileList.results.svn_directory & fileList.results.svn_name />
				<cfset currentJSPath = jsStringFormat(currentPath) />
				<tr class="row2" id='row#currentRow#' onmouseover="highlightRow('row#currentRow#','on');" onmouseout="highlightRow('row#currentRow#','off');">
					<td valign="middle" align="center" bgcolor="##EEEEEE">
						<input id="#currentRow#" type="checkbox" name="pathsToUpdate" value="#fileList.results.type#_#currentPath#" onclick="if (this.checked){highlightRow('row#currentRow#','selected');}else{highlightRow('row#currentRow#','reset');}" />
					</td>
					<td valign="middle" align="center">	
						<cfif fileList.results.type eq 'dir'>
							<img src="./asset/image/folder.gif" border="0" />
						<cfelseif fileList.results.type eq 'file' and (listFindNoCase(application.vars.binaryFileExt,listLast(fileList.results.svn_name,'.')) or flag eq 'white')>
							<img title="File Cannot Be Viewed" src="./asset/image/file.gif" border="0" />
						<cfelseif fileList.results.type eq 'file' and listFindNoCase(application.vars.textFileExt,listLast(fileList.results.svn_name,'.'))>
							<a href="##" onClick="viewFile('#currentJSPath#',0);"><img title="View Code" alt="View Code" src="./asset/image/viewcode.gif" border="0" /></a>
						<cfelseif fileList.results.type eq 'file' and listFindNoCase(application.vars.imageFileExt,listLast(fileList.results.svn_name,'.'))>
							<a href="##" onClick="viewFile('#currentJSPath#',0);"><img title="View Image" alt="View Image" src="./asset/image/viewimage.gif" border="0" /></a>
						<cfelseif fileList.results.type eq 'file'>
							<a href="##" onClick="viewFile('#currentJSPath#',0);"><img src="./asset/image/file.gif" border="0" title="#fileList.results.svn_name#" /></a>
						</cfif>
					</td>
					<td valign="middle" style="padding-left:5px;padding-right:5px;" title="svn: #currentPath# | local: #fileList.results.local_directory##fileList.results.local_name#">
						<cfif fileList.results.type eq 'dir'>							
							<a href="##" onClick="changePath('#currentJSPath#');">#fileList.results.svn_name#</a>
						<cfelseif listFindNoCase(application.vars.textFileExt,listLast(fileList.results.svn_name,'.')) or listFindNoCase(application.vars.imageFileExt,listLast(fileList.results.svn_name,'.'))>
							<a href="##" onClick="viewFile('#currentPath#',0);">#fileList.results.svn_name#</a>
						<cfelseif listFindNoCase(application.vars.binaryFileExt,listLast(fileList.results.svn_name,'.'))>
							#fileList.results.svn_name#
						<cfelse>
							#fileList.results.svn_name#
						</cfif>
					</td>
					<td valign="middle" align="center" title="svn: #dateFormat(fileList.results.svn_datetime,'mm/dd/yyyy')# #timeFormat(fileList.results.svn_datetime,'HH:mm:ss')# | local: #dateFormat(fileList.results.local_datetime,'mm/dd/yyyy')# #timeFormat(fileList.results.local_datetime,'HH:mm:ss')#">								
						#dateFormat(fileList.results.svn_datetime,'mm/dd/yyyy')# #timeFormat(fileList.results.svn_datetime,'hh:mm:ss tt')#
					</td>
					<td valign="middle" align="center">									
						#fileList.results.revision#
					</td>
					<td valign="middle" align="center" title="#fileList.results.status# - #fileList.results.message#">								
						<img src="./asset/image/flag_#fileList.results.flag#.gif" border="0" alt="#fileList.results.status#" />
					</td>
					<td valign="middle" align="center" title="svn: #fileList.results.svn_size# | local: #fileList.results.local_size#">									
						#fileList.results.svn_size#
					</td>	
					<td valign="middle" align="center">
						<!--- local directories --->
						<cfif fileList.results.type eq 'dir' and status eq 'DNE-SVN'>
							<a href="##" onClick="deleteDirectory('#currentJsPath#');"><img title="Delete Local File" width="16" height="16" src="./asset/image/delete.gif" border="0" align="absmiddle" alt="Delete"></a>							
						<!--- svn directories --->
						<cfelseif fileList.results.type eq 'dir'>
							<a href="##" onClick="exportZip('#currentJsPath#');"><img title="Export Directory To Zip" width="16" height="16" src="./asset/image/zip.gif" border="0" align="absmiddle" alt="Zip"></a>
						<!--- local files --->
						<cfelseif fileList.results.type eq 'file' and status eq 'DNE-SVN'>
							<a href="##" onClick="deleteFile('#currentJsPath#');"><img title="Delete Local File" width="16" height="16" src="./asset/image/delete.gif" border="0" align="absmiddle" alt="Delete"></a>
						<!--- svn files --->
						<cfelseif fileList.results.type eq 'file'>
							<a href="##" onClick="exportFile('#currentPath#');"><img title="Get File" width="16" height="16" src="./asset/image/getfile.gif" border="0" align="absmiddle" alt="Get"></a>
							|
							<a href="##" onClick="viewDiff('#currentJSPath#',-1,#fileList.results.revision#);"><img title="Diff Current Revision to Local File" width="16" height="16" src="./asset/image/diff_local.gif" border="0" align="absmiddle" alt="Diff - Current Revision to Local"></a>
							<a href="##" onClick="viewDiff('#currentJSPath#',-1,0);"><img title="Diff - HEAD to Local File" width="16" height="16" src="./asset/image/diff_rev.gif" border="0" align="absmiddle" alt="Diff - HEAD to Local"></a>
						</cfif>
						<!--- files only in svn --->
						<cfif status neq 'DNE-SVN'>
							|
							<a href="##" onClick="viewLog('#currentJSPath#','#fileList.results.type#',#fileList.results.revision#);" name="Log"><img title="Log" width="16" height="16" src="./asset/image/log.gif" border="0" align="absmiddle" alt="Log"></a>
							<a href="##" onClick="viewLog('#currentJSPath#','#fileList.results.type#',0);"><img title="Log History" width="16" height="16" src="./asset/image/logHistory.gif" border="0" align="absmiddle" alt="Log History"></a>
						</cfif>
					</td>		
				</tr>
			</cfloop>
		</cfif>
		<tr>
			<td colspan="8" bgcolor="##EEEEEE">&nbsp;</td>
		</tr>
	</table>
	</form>
</cfoutput>

<script>
	refreshRows();
</script>