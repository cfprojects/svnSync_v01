<cfsetting requesttimeout="#application.vars.svnRequestTimeout#" />

<cfparam name="url.browserPath" default="/" />
<cfparam name="url.revision" default="0" />
<cfparam name="url.type" default="dir" />
<cfset currentJSPath = jsStringFormat(url.browserPath) />
		
<cfswitch expression="#listLast(url.event,'.')#">
	
	<cfcase value="syncBrowser">
		<cfparam name="url.sortBy" default="type,svn_name" />
		<cfparam name="url.sortDir" default="asc" />
		<cfparam name="url.browserPath" default="/" />
		<cfparam name="url.revision" default="0" />
		<cfparam name="url.type" default="dir" />
		<cfparam name="parentPath" default="/" />
				
		<cfset url.browserPath = udf.rewritePath(path = url.browserPath) />
		<cfset localRootPath = udf.rewritePath(path = application.vars.localRootPath) />
		
		<cfif url.browserPath neq '/' and listLen(url.browserPath,'/')>
			<cfset parentPath = listDeleteAt(url.browserPath,listLen(url.browserPath,'/'),'/') & '/' />
		<cfelse>
			<cfset url.browserPath =  '/' />
		</cfif>
		
		<cfset fileList = application.com.objectFactory.getInstance('syncService').listLocalFiles(
																							svnUsername = application.vars.svnUsername,
																							svnPassword = application.vars.svnPassword,
																							repoURL = application.vars.repoURL,
																							svnPath = application.vars.svnPath,
																							syncToPath = url.browserPath,
																							localRootPath = localRootPath,
																							revision = url.revision,
																							gmt = application.vars.gmt) />
		<cfif fileList.success>
			<!--- sort results --->
			<cfquery dbtype="query" name="fileList.results" result="qres">
				SELECT *, upper(svn_name) AS upper_name FROM fileList.results
				ORDER BY #replaceNoCase(url.sortBy,'svn_name','upper_name')# #url.sortDir#
			</cfquery>
		<cfelse>
			<cfset msg = fileList.error.message />
		</cfif>
		<cfinclude template="../view/svnSync/menu.cfm" />
		<cfinclude template="../view/include/msgBar.cfm" />
		<cfinclude template="../view/svnSync/index.cfm" />
	</cfcase>

	<cfcase value="export">
		<cfparam name="url.browserPath" default="/" />
		<cfparam name="url.revision" default="0" />
		<cfparam name="url.type" default="file" />

		<cfscript>
			targetPath = udf.rewritePath(path = udf.rewritePath(application.vars.localRootPath) & udf.rewritePath(url.browserPath), type = url.type);
			svnURL = udf.rewriteURL(path = udf.rewriteURL(application.vars.repoURL) & udf.rewritePath(application.vars.svnPath) & udf.rewritePath(url.browserPath), type = url.type);
			export = application.com.objectFactory.getInstance('svnService').export(
																					svnUsername = application.vars.svnUsername,
																					svnPassword = application.vars.svnPassword,
																					svnURL = svnURL,
																					targetPath = targetPath,
																					revision = url.revision);
		</cfscript>
		<script language="javascript">
			parent.document.browserForm.submit();
		</script>
	</cfcase>
	
	<cfcase value="showDiff">
		<cfparam name="url.browserPath" default="/" />
		<cfparam name="url.revision" default="-1" />
		<cfparam name="url.diffRevision" default="0" />

		<cfscript>
			url.browserPath = udf.rewritePath(path = url.browserPath, type = 'file');
			localRootPath = udf.rewritePath(path = udf.rewritePath(application.vars.localRootPath) & udf.rewritePath(url.browserPath), type = 'file');
			svnURL = udf.rewriteURL(path = udf.rewriteURL(application.vars.repoURL) & udf.rewritePath(application.vars.svnPath) & udf.rewritePath(url.browserPath), type = 'file');
			
			oldFile = application.com.objectFactory.getInstance('svnService').viewFile(
																					svnUsername = application.vars.svnUsername,
																					svnPassword = application.vars.svnPassword,
																					svnURL = svnURL,
																					revision = url.diffRevision);
		</cfscript>
		
		<!--- compare to local file --->
		<cfif url.revision lt 0>
			<cffile action="read" file="#localRootPath#" variable="newFile">
		<!--- compare svn revisions --->
		<cfelse>
			<cfscript>
				newFile = application.com.objectFactory.getInstance('svnService').viewFile(
																					svnUsername = application.vars.svnUsername,
																					svnPassword = application.vars.svnPassword,
																					svnURL = svnURL,
																					revision = url.revision);
			</cfscript>
		</cfif>
		
		<!--- convert to arrays for comparison --->
		<cfset oldArray = ListToArray(oldFile,Chr(10))>
		<cfset newArray = ListToArray(newFile,Chr(10))>
		<!--- calculate differences --->
		<cfset Q = application.com.objectFactory.getInstance('diff').DiffArrays(oldArray,newArray)>
		<cfset P = application.com.objectFactory.getInstance('diff').Parallelize(Q,oldArray,newArray)>
		<!--- set up identifiers --->
		<cfset OpClasses=StructNew()>
		<cfset OpClasses["+"]="ins">
		<cfset OpClasses["-"]="del">
		<cfset OpClasses["!"]="upd">
		<cfset OpClasses[""]="">
		<!--- display diff view --->
		<cfinclude template="../view/svnSync/diff.cfm" />																
	</cfcase>
	
	<cfcase value="deleteFile">
		<cfparam name="url.sortBy" default="type,svn_name" />
		<cfparam name="url.sortDir" default="asc" />
		<cfparam name="url.browserPath" default="/" />
		<cfparam name="url.revision" default="0" />
		<cfparam name="url.deletePath" default="" />
		
		<cfscript>
			if (len(url.deletePath) and (udf.rewritePath(url.deletePath, 'file') neq '/')){
				targetPath = udf.rewritePath(path = udf.rewritePath(application.vars.localRootPath) & udf.rewritePath(url.deletePath, 'file'), type = 'file');			
				deleteFile = application.com.objectFactory.getInstance('localFileService').deleteFile(targetPath);
				if (deleteFile){
					msg = 'Deleted Successfully';
				}else{
					msg = 'Error Deleting File, It May Not Exist';
				}
			}else{
				msg = 'Invalid Path';
			}	
		</cfscript>
		<cflocation addtoken="no" url="index.cfm?event=svnSync.syncBrowser&sortBy=#url.sortBy#&sortDir=#url.sortDir#&browserPath=#url.browserPath#&revision=#url.revision#&msg=#msg#" />
	</cfcase>
	
	<cfcase value="deleteDirectory">
		<cfparam name="url.sortBy" default="type,svn_name" />
		<cfparam name="url.sortDir" default="asc" />
		<cfparam name="url.browserPath" default="/" />
		<cfparam name="url.revision" default="0" />
		<cfparam name="url.deletePath" default="" />

		<cfscript>
			if (len(url.deletePath) and (udf.rewritePath(url.deletePath) neq '/')){
				targetPath = udf.rewritePath(path = udf.rewritePath(application.vars.localRootPath) & udf.rewritePath(url.deletePath));
				deleteDirectory = application.com.objectFactory.getInstance('localFileService').deleteDirectory(targetPath);
				if (deleteDirectory){
					msg = 'Deleted Successfully';
				}else{
					msg = 'Error Deleting Directory, It May Not Exist';
				}
			}else{
				msg = 'Invalid Path';
			}
		</cfscript>
		<cflocation addtoken="no" url="index.cfm?event=svnSync.syncBrowser&sortBy=#url.sortBy#&sortDir=#url.sortDir#&browserPath=#url.browserPath#&revision=#url.revision#&msg=#msg#" />
	</cfcase>
	
	<cfcase value="viewFile">
		<cfparam name="url.browserPath" default="/" />
		<cfparam name="url.revision" default="0" />
		<cfparam name="img_mime" default="" />

		<cfset ext = listLast(url.browserPath,'.') />
	
		<cfif ListFindNoCase('jpeg,jpg', ext)>
			<cfset img_mime = "image/jpeg">
		<cfelseif ListFindNoCase('gif', ext)>
			<cfset img_mime = "image/gif">
		<cfelseif ListFindNoCase('bmp', ext)>
			<cfset img_mime = "image/bmp">
		</cfif>

		<cfscript>
			svnURL = udf.rewriteURL(path = udf.rewriteURL(application.vars.repoURL) & udf.rewritePath(application.vars.svnPath) & udf.rewritePath(url.browserPath), type = 'file');
			viewFile = application.com.objectFactory.getInstance('svnService').viewFile(
																					svnUsername = application.vars.svnUsername,
																					svnPassword = application.vars.svnPassword,
																					svnURL = svnURL,
																					revision = url.revision);
		</cfscript>
	
		
		<cfif len(img_mime)>
			<cfheader name="Content-Disposition" value="filename=temp.#ext#">
			<cfcontent type="#img_mime#" reset="yes"><cfoutput>#toString(viewFile)#</cfoutput>
			<cfabort>
		<cfelseif len(viewFile) gt 500000>
			File Is Too Large To Preview
		<cfelse>
			<cfinclude template="../view/svnSync/viewFile.cfm" />
		</cfif>
	</cfcase>
	
	<cfcase value="getLog">
		<cfparam name="url.browserPath" default="/" />
		<cfparam name="url.revision" default="0" />
		<cfparam name="url.type" default="dir" />
		
		<cfscript>
			svnURL = udf.rewriteURL(path = udf.rewriteURL(application.vars.repoURL) & udf.rewritePath(application.vars.svnPath) & udf.rewritePath(url.browserPath), type = url.type);
			detailedLog = application.com.objectFactory.getInstance('svnService').getLog(
																						svnUsername = application.vars.svnUsername,
																						svnPassword = application.vars.svnPassword,
																						svnURL = svnURL,
																						revision = url.revision);
		</cfscript>
		<cfif url.layout neq 'popUp'>
			<cfinclude template="../view/svnSync/menu.cfm" />
		</cfif>		
		<cfinclude template="../view/include/msgBar.cfm" />
		<cfinclude template="../view/svnSync/log.cfm" />
	</cfcase>
	
	<cfcase value="getDetailedLog">
		<cfparam name="url.browserPath" default="/" />
		<cfparam name="url.revision" default="0" />
		<cfparam name="url.type" default="file" />
				
		<cfscript>
			svnURL = udf.rewriteURL(path = udf.rewriteURL(application.vars.repoURL) & udf.rewritePath(application.vars.svnPath) & udf.rewritePath(url.browserPath), type = url.type);
			detailedLog = application.com.objectFactory.getInstance('svnService').getDetailedLog(
																					svnUsername = application.vars.svnUsername,
																					svnPassword = application.vars.svnPassword,
																					svnURL = svnURL,
																					revision = url.revision);			
		</cfscript>
		<cfif url.layout neq 'popUp'>
			<cfinclude template="../view/svnSync/menu.cfm" />
		</cfif>
		<cfinclude template="../view/include/msgBar.cfm" />
		<cfinclude template="../view/svnSync/detailedLog.cfm" />														
	</cfcase>	
	
	<cfcase value="getFile">
		<cfparam name="url.browserPath" default="/" />
		<cfparam name="url.revision" default="0" />
		<cfparam name="url.isLog" default="false" />
		
		<cfscript>
			url.browserPath = udf.rewritePath(path = url.browserPath, type = 'file');
			svnURL = udf.rewriteURL(path = udf.rewriteURL(application.vars.repoURL) & udf.rewritePath(application.vars.svnPath) & udf.rewritePath(url.browserPath), type = 'file');
			
			if (url.isLog){
				tmpFileName = getFileFromPath(url.browserPath) & '-rev' & url.revision;
			}else{
				tmpFileName = getFileFromPath(url.browserPath);
			}
			
			getFile = application.com.objectFactory.getInstance('svnService').downloadFile(
																					svnUsername = application.vars.svnUsername,
																					svnPassword = application.vars.svnPassword,
																					svnURL = svnURL,
																					revision = url.revision,
																					fileName = tmpFileName);
		</cfscript>
	</cfcase>
	
	<cfcase value="exportZip">
		<cfparam name="url.browserPath" default="/" />
		<cfparam name="url.revision" default="0" />
		<cfparam name="url.isLog" default="false" />
		 
		<cfscript>
			url.browserPath = udf.rewritePath(path = url.browserPath);
			svnURL = udf.rewriteURL(path = udf.rewriteURL(application.vars.repoURL) & udf.rewritePath(application.vars.svnPath) & udf.rewritePath(url.browserPath), type = 'file');
			
			if (url.browserPath eq '/'){
				url.browserPath = getDirectoryFromPath(udf.rewritePath(application.vars.svnPath));	
			}
			
			tmpFileName = replace(url.browserPath,'/','-','all');
			
			if (left(tmpFileName,1) eq '-'){
				tmpFileName = right(tmpFileName,len(tmpFileName)-1);
			}else if (right(tmpFileName,1) eq '-'){
				tmpFileName = left(tmpFileName,len(tmpFileName)-1);
			}
			
			if (url.isLog){
				tmpFileName = tmpFileName & '_rev' & url.revision;
			}
			
			getFile = application.com.objectFactory.getInstance('svnService').exportZip(
																					svnUsername = application.vars.svnUsername,
																					svnPassword = application.vars.svnPassword,
																					svnURL = svnURL,
																					revision = url.revision,
																					fileName = tmpFileName);
		</cfscript>
	</cfcase>
	
	<cfcase value="syncFiles">
		<cfparam name="url.sortBy" default="type],[name" />
		<cfparam name="url.sortDir" default="asc" />	
		<cfparam name="url.browserPath" default="/" />
		<cfparam name="url.pathsToUpdate" default="" />
		<cfparam name="url.revision" default="0" />

		<cfif len(url.pathsToUpdate)>
			<cfscript>
				url.browserPath = udf.rewritePath(path = url.browserPath);
				localRootPath = udf.rewritePath(path = application.vars.localRootPath);
				svnURL = udf.rewriteURL(path = udf.rewriteURL(application.vars.repoURL) & udf.rewritePath(application.vars.svnPath) & udf.rewritePath(url.browserPath));
			</cfscript>

			<cfloop list="#url.pathsToUpdate#" index="tmpItem">
				<cfset tmpType = listFirst(tmpItem,'_') />
				<cfset tmpPath = '/' & udf.rewritePath(replace(tmpItem,tmpType & '_',''),tmpType) />
	
				<cfset svnPath = udf.rewriteURL(path = application.vars.repoURL & application.vars.svnPath & tmpPath, type = tmpType) />
				<cfset localPath = udf.rewritePath(path = udf.rewritePath(application.vars.localRootPath) & tmpPath, type = tmpType) />

				<cfset application.com.objectFactory.getInstance('svnService').export(
																					svnUsername = application.vars.svnUsername,
																					svnPassword = application.vars.svnPassword,
																					svnURL = svnPath,
																					targetPath = localPath,
																					revision = url.revision) />
			</cfloop>
		</cfif>
		<cflocation addtoken="no" url="index.cfm?event=svnSync.syncBrowser&sortBy=#url.sortBy#&sortDir=#url.sortDir#&browserPath=#url.browserPath#&revision=#url.revision#" />
	</cfcase>
	
	<cfcase value="syncToRevision">
		<cfparam name="url.browserPath" default="/" />
		<cfparam name="url.revision" default="0" />
				
		<cfset url.browserPath = udf.rewritePath(path = url.browserPath) />
		<cfset localRootPath = udf.rewritePath(path = application.vars.localRootPath) />

		<cfscript>
			svnURL = udf.rewriteURL(path = udf.rewriteURL(application.vars.repoURL) & udf.rewritePath(application.vars.svnPath) & udf.rewritePath(url.browserPath));
			svnLog = application.com.objectFactory.getInstance('svnService').getDetailedLog(
																					svnUsername = application.vars.svnUsername,
																					svnPassword = application.vars.svnPassword,
																					svnURL = svnURL,
																					revision = url.revision);			
		</cfscript>
		
		<cfif svnLog.paths.recordCount>
			<cfloop query="svnLog.paths">
				<cfparam name="pathType" default="dir" />
				
				<cfif len(getFilefromPath(svnLog.paths.path))>
					<cfset pathType = 'file'>
				</cfif>
				
				<cfset svnPath = udf.rewriteURL(path = application.vars.repoURL & svnLog.paths.path, type = pathType) />
				<cfset localPath = udf.rewritePath(path = application.vars.localRootPath & replace(svnLog.paths.path,application.vars.svnPath,''), type = pathType) />

				<cfset application.com.objectFactory.getInstance('svnService').export(
																				svnUsername = application.vars.svnUsername,
																				svnPassword = application.vars.svnPassword,
																				svnURL = svnPath,
																				targetPath = localPath,
																				revision = url.revision) />
			</cfloop>
			<cfset msg = "Synchronized Successfully!" />
		<cfelse>
			<cfset msg = "Nothing To Synchronize" />
		</cfif>

		<cfinclude template="../view/svnSync/menu.cfm" />
		<cfinclude template="../view/include/msgBar.cfm" />
		<cfinclude template="../view/svnSync/syncResult.cfm" />
	</cfcase>
																			
</cfswitch>