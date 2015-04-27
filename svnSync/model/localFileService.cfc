<cfcomponent>
	<cffunction name="init" access="public" output="No" returntype="localFileService">
		<cfargument name="objectFactory" required="Yes" />
		<cfscript>
			// hold components
			variables.com = structNew();
			
			// objectFactory
			variables.com.objectFactory 	= arguments.objectFactory;
			variables.com.udf 				= variables.com.objectFactory.getInstance('udf');
			variables.com.zip 				= variables.com.objectFactory.getInstance('zip');
			
			variables.instance = structNew();
			variables.instance.tmpPath		= application.vars.localTempPath;
			
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="getDetailedLog" access="public" output="No" returntype="any">
		<cfargument name="name" required="true" type="string" />
		<cfargument name="path" required="false" type="string" default="">
		<cfargument name="limit" required="false" type="numeric" default="1000">
		<cfargument name="revision" required="false" type="numeric" default="0">

		<cfreturn variables.com.svnClient.getDetailedLog( argumentCollection=arguments ) />
	</cffunction>

	<cffunction name="listFiles" access="public" output="No" returntype="query">
		<cfargument name="path" required="true" type="string" default="" />
		<cfargument name="recursive" required="false" type="boolean" default="false" />

		<cfset var qFileList = '' />

		<cfdirectory action="list" directory="#arguments.path#" name="qFileList" recurse="#arguments.recursive#" />

		<cfreturn qFileList />
	</cffunction>

	<cffunction name="downloadFile" access="public" output="No" returntype="void">
		<cfargument name="path" required="true" type="string" />
		
		<cfset var fileName = getFileFromPath(arguments.path) />

		<cfheader name="Content-Disposition" value="attachment;filename=""#fileName#""" >
		<cfcontent file="#arguments.path#" type="application/unknown" />
		
	</cffunction>
	
	<cffunction name="viewFile" access="public" output="No" returntype="string">
		<cfargument name="path" required="true" type="string" />
		
		<cfset var fileData = '' />
	
		<cffile action="read" file="#arguments.path#" variable="fileData" />
		
		<cfreturn fileData />
	</cffunction>
	
	<cffunction name="deleteFile" access="public" output="No" returntype="string">
		<cfargument name="path" required="true" type="string" />
		
		<cfif fileExists(arguments.path)>
			<cffile action="delete" file="#arguments.path#" />
			<cfreturn true />
		</cfif>
		
		<cfreturn false />
	</cffunction>
	
	<cffunction name="deleteDirectory" access="public" output="No" returntype="string">
		<cfargument name="path" required="true" type="string" />
		
		<cfif directoryExists(arguments.path)>
			<cfdirectory action="delete" directory="#arguments.path#" />
			<cfreturn true />
		</cfif>
		
		<cfreturn false />
	</cffunction>
	
	<cffunction name="createDirectory" access="public" output="No" returntype="string">
		<cfargument name="path" required="true" type="string" />
		
		<cfif not directoryExists(arguments.path)>
			<cfdirectory action="create" directory="#arguments.path#" />
			<cfreturn true />
		</cfif>
		
		<cfreturn false />
	</cffunction>

	<cffunction name="export" access="public" output="No" returntype="void">
		<cfargument name="name" required="true" type="string" />
		<cfargument name="path" required="true" type="string" default="" />
		<cfargument name="folder" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" />

		<cfset variables.com.svnClient.export( argumentCollection=arguments ) />
	</cffunction>

	<cffunction name="exportZip" access="public" output="No" returntype="void">
		<cfargument name="path" required="true" type="string" />
		<cfargument name="fileName" required="false" type="string" default="" />

		<!--- zip tmp directory --->
		<cfscript>
			var tmpUUID = createUUID();
			
			if (not len(arguments.fileName))
			{
				arguments.fileName = listLast(arguments.path,'\');
			}
			
			if ( DirectoryExists(arguments.path) ) {
				variables.com.zip.AddFiles(
					zipFilePath = "#variables.instance.tmpPath#\#tmpUUID#.zip",
					directory = "#arguments.path#",
					recurse = true
					);
			}
		</cfscript>
		
		<cfheader name="Content-Disposition" value="attachment;filename=""#arguments.fileName#.zip""" >
		<cfcontent file="#variables.instance.tmpPath#/#tmpUUID#.zip" type="application/unknown" deletefile="Yes" />
		
	</cffunction>

</cfcomponent>