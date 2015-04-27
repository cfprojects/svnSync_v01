<cfcomponent>
	<cffunction name="init" access="public" output="false" returntype="syncService">
		<cfargument name="objectFactory" required="Yes" />
		<cfscript>
			variables.instance = structNew();
			variables.instance.objectFactory 	= arguments.objectFactory;
			variables.instance.udf 				= variables.instance.objectFactory.getInstance('udf');	
			setShowHiddenFiles(false);
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="setShowHiddenFiles" access="public" returntype="void" output="false">
		<cfargument name="showHidden" type="boolean" required="true" />
		<cfset variables.instance.showHidden = arguments.showHidden />
	</cffunction>
	
	<cffunction name="getShowHiddenFiles" access="public" returntype="boolean" output="false">
		<cfreturn variables.instance.showHidden />
	</cffunction>
	
	<cffunction name="getObjectFactory" access="private" returntype="any" output="false">
		<cfreturn variables.instance.objectFactory />
	</cffunction>
	
	<cffunction name="getUDF" access="private" returntype="any" output="false">
		<cfreturn variables.instance.udf />
	</cffunction>
	
	<cffunction name="listLocalFiles" access="public" output="false" returntype="struct">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="repoURL" required="true" type="string" />
		<cfargument name="svnPath" required="false" type="string" default="/" />
		<cfargument name="localRootPath" required="true" type="string" />
		<cfargument name="syncToPath" required="false" type="string" default="/" />
		<cfargument name="gmt" required="false" type="numeric" default="-5" />
		<cfargument name="revision" required="false" type="numeric" default="0" />
		<cfargument name="recursive" required="false" type="boolean" default="false" />

		<cfset var localRewritePath = '/' />
		<cfset var localRelativePath = '/' />
		<cfset var svnRelativePath = '/' />
		<cfset var svnFileList = '' />
		<cfset var localFileList = '' />		
		<cfset var outOfSync = '' />
		<cfset var localFileArray = arrayNew(2) />
		<cfset var svnFileArray = arrayNew(2) />
		<cfset var i = 0 />
		<cfset var tmpDate = '' />
		<cfset var gmtDate = '' />
		
		<cfset var stReturn = structNew() />
		<cfset stReturn.success = true />
		<cfset stReturn.results = queryNew('local_path,local_directory,local_name,local_datetime,local_size,svn_path,svn_directory,svn_name,svn_datetime,type,svn_size,revision,status,flag,message',
											'varchar,varchar,varchar,time,integer,varchar,varchar,varchar,time,varchar,integer,integer,varchar,varchar,varchar') />
		
		<cftry>
		<!--- format paths and URLs --->
		<cfset arguments.repoURL = getUDF().rewriteURL(arguments.repoURL) />
		<cfset arguments.svnPath = getUDF().rewritePath(arguments.svnPath) />
		<cfset arguments.syncToPath = getUDF().rewritePath(arguments.syncToPath) />
		<cfset arguments.localRootPath = getUDF().rewritePath(arguments.localRootPath) />
		<cfset arguments.localPath = getUDF().rewritePath(arguments.localRootPath & arguments.syncToPath) />
		<cfset arguments.svnURL = getUDF().rewriteURL(arguments.repoURL & arguments.svnPath & arguments.syncToPath) />

		<cfset stReturn.localPath = arguments.localPath />
		<cfset stReturn.svnURL = arguments.svnURL />

		<cfif not directoryExists(arguments.localPath)>
			<cfthrow message="Local Directory Does Not Exist - #arguments.localPath#" />
		</cfif>
		
		<!--- build initial filelists --->
		<cfset svnFileList = getObjectFactory().getInstance('svnService').listFiles(svnUsername = arguments.svnUsername, svnPassword = arguments.svnPassword, svnURL = arguments.svnURL, revision = arguments.revision, recursive = arguments.recursive) />
		<cfset localFileList = getObjectFactory().getInstance('localFileService').listFiles(path = arguments.localPath, recursive = arguments.recursive) />		
		
		<!--- filter out hidden files --->
		<cfif not getShowHiddenFiles()>
			<cfquery name="localFileList" dbtype="query">
				select attributes,datelastmodified,directory,mode,name,size,type
				from localFileList
				where attributes not in ('H')
			</cfquery>
		</cfif>
		
		<!--- format local file list --->
		<cfloop query="localFileList">
			<cfset localRewritePath = getUDF().rewritePath(directory) />

			<cfif localRewritePath neq arguments.localRootPath>
				<cfset localRelativePath = replace(localRewritePath,arguments.localRootPath,'') />	
			</cfif>
			
			<cfset localFileArray[currentRow][1] = localRelativePath />
			<cfset localFileArray[currentRow][2] = localFileList.name />
			
			<cfset querySetCell(localFileList, 'directory', localFileArray[currentRow][1], currentRow ) />
			<cfset querySetCell(localFileList, 'type', lcase(localFileList.type), currentRow ) />
		</cfloop>
		
		<cfset QueryAddColumn(svnFileList, 'svn_datetime', 'time', ArrayNew(1)) />
		<cfset QueryAddColumn(svnFileList, 'svn_directory', 'varchar', ArrayNew(1)) />
		
		<cfloop query="svnFileList">			
			<cfset svnFileArray[currentRow][1] = getUDF().rewritePath(arguments.syncToPath & listDeleteAt(svnFileList.name,listLen(svnFileList.name,'/'),'/')) />
			<cfset svnFileArray[currentRow][2] = getFileFromPath(svnFileList.name) />

			<cfset gmtDate = dateAdd('h',arguments.gmt,svnFileList.date) />
			<cfset tmpDate = createDateTime(datePart('yyyy',gmtDate),datePart('m',gmtDate),datePart('d',gmtDate),datePart('h',gmtDate),datePart('n',gmtDate),datePart('s',gmtDate)) />

			<cfset querySetCell(svnFileList, 'svn_directory', svnFileArray[currentRow][1], currentRow ) />
			<cfset querySetCell(svnFileList, 'name', svnFileArray[currentRow][2], currentRow ) />
			<cfset querySetCell(svnFileList, 'svn_datetime', tmpDate, currentRow ) />
		</cfloop>
		
		<!--- filter and format queries --->
		<cfquery name="svnFileList" dbtype="query">
			select svn_datetime, [kind] as type,[size] as svn_size, svn_directory, [name] as svn_name, [revision]
			from svnFileList
			order by svn_directory, svn_name
		</cfquery>
		
		<cfquery name="localFileList" dbtype="query">
			select [datelastmodified] as local_datetime, [type], [size] as local_size, [directory] as local_directory, [name] as local_name
			from localFileList
			order by local_directory, local_name
		</cfquery>
		
		<cfloop query="svnFileList">
			<cfquery name="outOfSync" dbtype="query">
				select * from localFileList
				where localFileList.local_name = '#svnFileList.svn_name#'
				and localFileList.local_directory = '#svnFileList.svn_directory#'
				and localFileList.type = '#svnFileList.type#'
			</cfquery>			
		
			<!--- file in SVN differs from local --->
			<cfif outOfSync.recordCount>
				<cfif svnFileList.svn_datetime gt outOfSync.local_datetime>
					<cfset queryAddRow(stReturn.results) />
					<cfset querySetCell(stReturn.results, 'local_directory',outOfSync.local_directory) />
					<cfset querySetCell(stReturn.results, 'local_name',outOfSync.local_name) />
					<cfset querySetCell(stReturn.results, 'local_size',outOfSync.local_size ) />
					<cfset querySetCell(stReturn.results, 'local_datetime',outOfSync.local_datetime ) />
					
					<cfset querySetCell(stReturn.results, 'svn_directory',svnFileList.svn_directory) />
					<cfset querySetCell(stReturn.results, 'svn_name',svnFileList.svn_name) />
					<cfset querySetCell(stReturn.results, 'svn_size',svnFileList.svn_size ) />
					<cfset querySetCell(stReturn.results, 'svn_datetime',svnFileList.svn_datetime ) />
					
					<cfset querySetCell(stReturn.results, 'type',outOfSync.type ) />
					<cfset querySetCell(stReturn.results, 'revision',svnFileList.revision ) />
					<cfset querySetCell(stReturn.results, 'status','OOS-DATE' ) />
					
					<cfif outOfSync.type eq 'file'>
						<cfset querySetCell(stReturn.results, 'flag','red' ) />
						<cfset querySetCell(stReturn.results, 'message','Local File Is Out Of Date' ) />
					<cfelse>
						<cfset querySetCell(stReturn.results, 'flag','orange' ) />
						<cfset querySetCell(stReturn.results, 'message','Directory Date Is Out Of Sync - Files May Be In Sync' ) />
					</cfif>
				<cfelseif svnFileList.type neq 'dir' and svnFileList.svn_size neq outOfSync.local_size>
					<cfset queryAddRow(stReturn.results) />
					<cfset querySetCell(stReturn.results, 'local_directory',outOfSync.local_directory) />
					<cfset querySetCell(stReturn.results, 'local_name',outOfSync.local_name) />
					<cfset querySetCell(stReturn.results, 'local_size',outOfSync.local_size ) />
					<cfset querySetCell(stReturn.results, 'local_datetime',outOfSync.local_datetime ) />
					
					<cfset querySetCell(stReturn.results, 'svn_directory',svnFileList.svn_directory) />
					<cfset querySetCell(stReturn.results, 'svn_name',svnFileList.svn_name) />
					<cfset querySetCell(stReturn.results, 'svn_size',svnFileList.svn_size ) />
					<cfset querySetCell(stReturn.results, 'svn_datetime',svnFileList.svn_datetime ) />
					
					<cfset querySetCell(stReturn.results, 'type',outOfSync.type ) />
					<cfset querySetCell(stReturn.results, 'revision',svnFileList.revision ) />
					<cfset querySetCell(stReturn.results, 'status','OOS-SIZE' ) />
					<cfset querySetCell(stReturn.results, 'flag','red' ) />
					<cfset querySetCell(stReturn.results, 'message','File Size Mismatch' ) />
				<cfelse>
					<cfset queryAddRow(stReturn.results) />
					<cfset querySetCell(stReturn.results, 'local_directory',outOfSync.local_directory) />
					<cfset querySetCell(stReturn.results, 'local_name',outOfSync.local_name) />
					<cfset querySetCell(stReturn.results, 'local_size',outOfSync.local_size ) />
					<cfset querySetCell(stReturn.results, 'local_datetime',outOfSync.local_datetime ) />
					
					<cfset querySetCell(stReturn.results, 'svn_directory',svnFileList.svn_directory) />
					<cfset querySetCell(stReturn.results, 'svn_name',svnFileList.svn_name) />
					<cfset querySetCell(stReturn.results, 'svn_size',svnFileList.svn_size ) />
					<cfset querySetCell(stReturn.results, 'svn_datetime',svnFileList.svn_datetime ) />
					
					<cfset querySetCell(stReturn.results, 'type',outOfSync.type ) />
					<cfset querySetCell(stReturn.results, 'revision',svnFileList.revision ) />
					<cfset querySetCell(stReturn.results, 'status','SYNC' ) />
					<cfset querySetCell(stReturn.results, 'flag','green' ) />
					<cfset querySetCell(stReturn.results, 'message','Up To Date' ) />
				</cfif>
				
				<cfset querySetCell(stReturn.results, 'svn_path', getUDF().rewriteURL(arguments.svnURL & svnFileList.svn_directory & svnFileList.svn_name,svnFileList.type)) />
				<cfset querySetCell(stReturn.results, 'local_path', getUDF().rewritePath(arguments.localPath & outOfSync.local_directory & outOfSync.local_name,outOfSync.type)) />
			<cfelse>
				<cfset queryAddRow(stReturn.results) />	
				<cfset querySetCell(stReturn.results, 'local_directory',svnFileList.svn_directory) />
				<cfset querySetCell(stReturn.results, 'local_name',svnFileList.svn_name) />
				<cfset querySetCell(stReturn.results, 'local_size',svnFileList.svn_size ) />
				<cfset querySetCell(stReturn.results, 'local_datetime',svnFileList.svn_datetime ) />
							
				<cfset querySetCell(stReturn.results, 'svn_directory',svnFileList.svn_directory) />
				<cfset querySetCell(stReturn.results, 'svn_name',svnFileList.svn_name) />
				<cfset querySetCell(stReturn.results, 'svn_size',svnFileList.svn_size ) />
				<cfset querySetCell(stReturn.results, 'svn_datetime',svnFileList.svn_datetime ) />
				
				<cfset querySetCell(stReturn.results, 'type',svnFileList.type ) />
				<cfset querySetCell(stReturn.results, 'revision',svnFileList.revision ) />
				<cfset querySetCell(stReturn.results, 'status','DNE-LOC' ) />
				<cfset querySetCell(stReturn.results, 'flag','blue' ) />
				<cfset querySetCell(stReturn.results, 'message','Does Not Exist Locally') />
				
				<cfset querySetCell(stReturn.results, 'svn_path', getUDF().rewriteURL(arguments.svnURL & svnFileList.svn_directory & svnFileList.svn_name,svnFileList.type)) />
				<cfset querySetCell(stReturn.results, 'local_path', getUDF().rewritePath(arguments.localPath & svnFileList.svn_directory & svnFileList.svn_name,svnFileList.type)) />
			</cfif>
		</cfloop>

		<!-- files not in SVN --->
		<cfset localFileArray.removeAll(svnFileArray) />

		<cfif arrayLen(localFileArray)>
			<cfloop from="1" to="#arrayLen(localFileArray)#" step="1" index="i">
				<cfquery name="outOfSync" dbtype="query">
					select * from localFileList
					where localFileList.local_name = '#localFileArray[i][2]#'
					and localFileList.local_directory = '#localFileArray[i][1]#'
				</cfquery>
		
				<cfset queryAddRow(stReturn.results) />
				<cfset querySetCell(stReturn.results, 'local_directory',outOfSync.local_directory) />
				<cfset querySetCell(stReturn.results, 'local_name',outOfSync.local_name) />
				<cfset querySetCell(stReturn.results, 'local_size',outOfSync.local_size ) />
				<cfset querySetCell(stReturn.results, 'local_datetime',outOfSync.local_datetime ) />
				
				<cfset querySetCell(stReturn.results, 'svn_directory',outOfSync.local_directory) />
				<cfset querySetCell(stReturn.results, 'svn_name',outOfSync.local_name) />
				<cfset querySetCell(stReturn.results, 'svn_size',outOfSync.local_size ) />
				<cfset querySetCell(stReturn.results, 'svn_datetime',outOfSync.local_datetime ) />
				
				<cfset querySetCell(stReturn.results, 'type',outOfSync.type ) />
				<cfset querySetCell(stReturn.results, 'status','DNE-SVN' ) />
				<cfset querySetCell(stReturn.results, 'flag','white' ) />
				<cfset querySetCell(stReturn.results, 'message','Not In SVN (Deleted,Old?)' ) />
				
				<cfset querySetCell(stReturn.results, 'svn_path', getUDF().rewriteURL(arguments.svnURL & outOfSync.local_directory & outOfSync.local_name,outOfSync.type)) />
				<cfset querySetCell(stReturn.results, 'local_path', getUDF().rewritePath(arguments.localPath & outOfSync.local_directory & outOfSync.local_name,outOfSync.type)) />
			</cfloop>
		</cfif>
		
		<!--- <cfdump var="#arguments#" label="svn">
		<cfdump var="#svnFileList#" label="svn">
		<cfdump var="#localFileList#" label="loc">
		<cfdump var="#stReturn.results#" label="tmp"> 
		<cfabort> 
		 --->
		<cfcatch type="any">
			<cfset stReturn.success = false />
			<cfset stReturn.error = cfcatch />
		</cfcatch>
		</cftry>
		<cfreturn stReturn />
	</cffunction>

	
</cfcomponent>