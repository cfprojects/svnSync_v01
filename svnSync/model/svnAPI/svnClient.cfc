<!---
Copyright: Rob Gonda.
Author: Rob Gonda (rob@robgonda.com)
$Id: $

Notes:
Performs svn client operations.
--->

<cfcomponent displayname="SVN Client">
	
	<!--- Constructor function --->
	<cffunction name="init" access="public" output="false" returntype="svnClient">
		<cfargument name="svnBinary" required="true" type="string" />
		<cfargument name="tmpPath" required="true" type="string" />

		<cfscript>
			variables.instance 					= structNew();
			variables.instance.svnBinary		= arguments.svnBinary;
			variables.instance.tmpPath			= arguments.tmpPath;
		</cfscript>
		
		<cfreturn this />
	</cffunction>
		
	<cffunction name="getLog" access="public" output="false" returntype="query">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0">
		
		<cfscript>
			var argString = '';
			var xmlLog = '';
			var xmlLogArray = arrayNew(1);
			var i = 0;
			var fixedDate = '';
			var logQry = queryNew('revision,author,date,msg','Integer,VarChar,VarChar,VarChar');
		</cfscript>
		
		<cfset argString = 'log --xml --no-auth-cache --username #arguments.svnUsername# --password #arguments.svnPassword# #arguments.svnURL#' />
		
		<cfif arguments.revision gt 0>
			<cfset argString = argString & ' -r ' & arguments.revision />
		</cfif>
		
		<cfexecute 
			name="#variables.instance.svnBinary#" 
			arguments="#argString#"
			timeout="600"
			variable="xmlLog" />

		<cfset xmlLog = xmlParse(xmlLog) />
		<cfset xmlLogArray = XMLSearch(xmlLog, '/log/logentry') />

		<cfloop from="1" to="#ArrayLen(xmlLogArray)#" index="i">
			<cfscript>
				queryAddRow(logQry);
				querySetCell(logQry, 'revision', xmlLogArray[i].XmlAttributes.revision);
				if (structKeyExists(xmlLogArray[i],'author')){
					querySetCell(logQry, 'author', xmlLogArray[i].author.XmlText);
				}else{
					querySetCell(logQry, 'author', 'anonymous');
				}
				fixedDate = xmlLogArray[i].date.XmlText;
				fixedDate = ListGetAt(fixedDate,1,'T') & ' ' & ListGetAt(ListGetAt(fixedDate,2,'T'),1,'.');
						
				querySetCell(logQry, 'date', fixedDate);
				querySetCell(logQry, 'msg', xmlLogArray[i].msg.XmlText);
				
			</cfscript>
		</cfloop>
		<cfreturn logQry />
	</cffunction>
	
	<cffunction name="getDetailedLog" access="public" output="false" returntype="struct">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0">
		
		<cfscript>
			var rtnStruct = structNew();
			var argString = '';
			var xmlLog = '';
			var xmlLogArray = arrayNew(1);
			var i = 0;
			var fixedDate = '';
			var logQry = queryNew('revision,author,date,msg,paths','integer,varchar,time,varchar,varchar');
			var pathsQry = queryNew('revision,path,action','integer,varchar,varchar');
			var tmpPos = 0;
		</cfscript>

		<cfset argString = 'log --verbose --xml --no-auth-cache --username #arguments.svnUsername# --password #arguments.svnPassword# #arguments.svnURL# -r ' />
		
		<cfif arguments.revision gt 0>
			<cfset argString = argString & arguments.revision />
		<cfelse>
			<cfset argString = argString & 'HEAD' />
		</cfif>

		<cfexecute 
			name="#variables.instance.svnBinary#" 
			arguments="#argString#"
			timeout="900"
			variable="xmlLog" />

		<cfset xmlLog = xmlParse(xmlLog) />
		<cfset xmlLogArray = XMLSearch(xmlLog, '/log/logentry') />
		
		<cfloop from="1" to="#ArrayLen(xmlLogArray)#" index="i">
			<cfscript>
				queryAddRow(logQry);
				querySetCell(logQry, 'revision', xmlLogArray[i].XmlAttributes.revision);
				if (structKeyExists(xmlLogArray[i],'author')){
					querySetCell(logQry, 'author', xmlLogArray[i].author.XmlText);
				}else{
					querySetCell(logQry, 'author', 'anonymous');
				}
				
				fixedDate = xmlLogArray[i].date.XmlText;
				fixedDate = ListGetAt(fixedDate,1,'T') & ' ' & ListGetAt(ListGetAt(fixedDate,2,'T'),1,'.');
						
				querySetCell(logQry, 'date', fixedDate);
				querySetCell(logQry, 'msg', xmlLogArray[i].msg.XmlText);		
			</cfscript>
			
			<cfloop from="1" to="#arrayLen(xmlLogArray[i].paths.path)#" step="1" index="tmpPos">
				<cfscript>
					queryAddRow(pathsQry);
					querySetCell(pathsQry, 'revision', xmlLogArray[i].XmlAttributes.revision);
					querySetCell(pathsQry, 'path', xmlLogArray[i].paths.path[tmpPos].xmlText);
					querySetCell(pathsQry, 'action', xmlLogArray[i].paths.path[tmpPos].xmlAttributes.action);
				</cfscript>
			</cfloop>
		</cfloop>
		
		<cfquery name="rtnStruct.paths" dbtype="query">
			select * from pathsQry
			order by path
		</cfquery>
		
		<cfset rtnStruct.log = logQry />
		
		<cfreturn rtnStruct />
	</cffunction>
	
	<cffunction name="list" access="public" output="No" returntype="query">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0" />	
		<cfargument name="recursive" required="false" type="boolean" default="false" />
		
		<cfscript>
			var argString = '';
			var xmlLog = '';
			var xmlLogArray = arrayNew(1);
			var i = 0;
			var i2 = 0;
			var logQry = queryNew('kind,name,size,revision,author,date','VarChar,VarChar,Integer,Integer,VarChar,VarChar');
			var tmp = '';
			var recursiveStr = iif(arguments.recursive, DE('-R'), DE(''));
		</cfscript>

		<cfif arguments.revision gt 0>
			<cfset arguments.svnURL = arguments.svnURL & '@' & arguments.revision />
		</cfif>
		
		<cfset argString = 'list --xml --no-auth-cache #recursiveStr# --username #arguments.svnUsername# --password #arguments.svnPassword# #arguments.svnURL#' />

		<cfexecute 
			name="#variables.instance.svnBinary#" 
			arguments="#argString#"
			timeout="600"
			variable="xmlLog" />
			
		<cfif not isXML(xmlLog)>
			<cfreturn logQry />
		</cfif>
		
		<cfset xmlLog = xmlParse(xmlLog) />
		<cfset xmlLogArray = XMLSearch(xmlLog, '/lists/list/entry') />
		
		<cfloop from="1" to="#ArrayLen(xmlLogArray)#" index="i">
			<cfset queryAddRow(logQry) />
			<cfset querySetCell(logQry, 'kind', xmlLogArray[i].XmlAttributes.kind) />
			<cfif ( xmlLogArray[i].XmlAttributes.kind eq 'dir' )>
				<cfset querySetCell(logQry, 'name', xmlLogArray[i].XmlChildren[1].XmlText) />
				<cfset querySetCell(logQry, 'revision', xmlLogArray[i].XmlChildren[2].XmlAttributes.revision) />
				<cfloop from="1" to="#ArrayLen(xmlLogArray[i].XmlChildren[2].XmlChildren)#" index="i2">
					<cfif listFind('author,date',xmlLogArray[i].XmlChildren[2].XmlChildren[i2].XmlName)>
						<cfset querySetCell(logQry, xmlLogArray[i].XmlChildren[2].XmlChildren[i2].XmlName, xmlLogArray[i].XmlChildren[2].XmlChildren[i2].XmlText) />
					</cfif>
				</cfloop>
			<cfelse>
				<cfset querySetCell(logQry, 'name', xmlLogArray[i].XmlChildren[1].XmlText) />
				<cfset querySetCell(logQry, 'size', xmlLogArray[i].XmlChildren[2].XmlText) />
				<cfset querySetCell(logQry, 'revision', xmlLogArray[i].XmlChildren[3].XmlAttributes.revision) />
				<cfloop from="1" to="#ArrayLen(xmlLogArray[i].XmlChildren[3].XmlChildren)#" index="i2">
					<cfif listFind('author,date',xmlLogArray[i].XmlChildren[3].XmlChildren[i2].XmlName)>
						<cfset querySetCell(logQry, xmlLogArray[i].XmlChildren[3].XmlChildren[i2].XmlName, xmlLogArray[i].XmlChildren[3].XmlChildren[i2].XmlText) />
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<!--- resort by folder/file --->
		<cfquery name="logQry" dbtype="query">
			select * from logQry
			order by [kind], [name]
		</cfquery>
		
		<cfloop query="logQry">
			<cfset tmp = ListGetAt(date,1,'T') & ' ' & ListGetAt(ListGetAt(date,2,'T'),1,'.') />
			<cfset querySetCell(logQry, 'date', tmp, currentRow) />
		</cfloop>
		
		<cfreturn logQry />
	</cffunction>

	<cffunction name="export" access="public" output="No" returntype="void">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="targetPath" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0" />
	
		<cfset var argString = '' />
	
		<cfif arguments.revision gt 0>
			<cfset arguments.svnURL = arguments.svnURL & '@' & arguments.revision />
		</cfif>

		<cfset argString = 'export --no-auth-cache --force --username #arguments.svnUsername# --password #arguments.svnPassword# #arguments.svnURL# "#arguments.targetPath#"' />

		<cfexecute 
			name="#variables.instance.svnBinary#" 
			arguments="#argString#"
			timeout="600" />
	</cffunction>

	<cffunction name="exportZip" access="public" output="no" returntype="void" hint="exports folder from repo and serves it as a zip file">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0" />
		<cfargument name="fileName" required="false" type="string" />
		
		<cfset var argString = '' />
		<cfset var tmpUUID = createUUID() />
		<cfset var zip = CreateObject("component", "Zip") />
	
		<cfif arguments.revision gt 0>
			<cfset arguments.svnURL = arguments.svnURL & '@' & arguments.revision />
		</cfif>

		<cfif not len(arguments.fileName)>
			<cfset arguments.fileName = getFileFromPath(arguments.svnURL) />
		</cfif>
		
		<cfset argString = 'export --no-auth-cache --force --username #arguments.svnUsername# --password #arguments.svnPassword# #arguments.svnURL# "#variables.instance.tmpPath#/#tmpUUID#"' />

		<cfexecute 
			name="#variables.instance.svnBinary#" 
			arguments="#argString#"
			timeout="600" />
		
		<cfif DirectoryExists("#variables.instance.tmpPath#\#tmpUUID#")>
			<cfset zip.AddFiles(
						zipFilePath = "#variables.instance.tmpPath#/#tmpUUID#.zip",
						directory = "#variables.instance.tmpPath#/#tmpUUID#",
						recurse = true) />
						
			<!--- remove tmp directory --->
			<cfdirectory action="DELETE" directory="#variables.instance.tmpPath#/#tmpUUID#" recurse="true" />
			
			<cfheader name="Content-Disposition" value="attachment;filename=""#arguments.fileName#.zip""" >
			<cfcontent file="#variables.instance.tmpPath#/#tmpUUID#.zip" type="application/unknown" deletefile="Yes" />
		</cfif>	
	</cffunction>

	<cffunction name="download" access="public" output="No" returntype="void">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0" />
		<cfargument name="fileName" required="false" type="string" />
		
		<cfset var argString = '' />
		<cfset var tmpUUID = createUUID() />
	
		<cfif arguments.revision gt 0>
			<cfset arguments.svnURL = arguments.svnURL & '@' & arguments.revision />
		</cfif>
		
		<cfif not len(arguments.fileName)>
			<cfset arguments.fileName = getFileFromPath(arguments.svnURL) />
		</cfif>
		
		<cfset argString = 'export --no-auth-cache --force --username #arguments.svnUsername# --password #arguments.svnPassword# #arguments.svnURL# "#variables.instance.tmpPath#/#tmpUUID#"' />

		<cfexecute 
			name="#variables.instance.svnBinary#" 
			arguments="#argString#"
			timeout="600" />

		<cfheader name="Content-Disposition" value="attachment;filename=""#arguments.fileName#""" >
		<cfcontent file="#variables.instance.tmpPath#/#tmpUUID#" type="application/unknown" deletefile="Yes" />
	</cffunction>

	<cffunction name="view" access="public" output="No" returntype="string">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0" />
		
		<cfset var argString = '' />
		<cfset var returnTXT = '' />
		<cfset var tmpUUID = createUUID() />
	
		<cfif arguments.revision gt 0>
			<cfset arguments.svnURL = arguments.svnURL & '@' & arguments.revision />
		</cfif>

		<cfset argString = 'export --no-auth-cache --force --username #arguments.svnUsername# --password #arguments.svnPassword# #arguments.svnURL# "#variables.instance.tmpPath#\#tmpUUID#"' />

		<cfexecute 
			name="#variables.instance.svnBinary#" 
			arguments="#argString#"
			timeout="600" />
		
		<cfif fileExists('#variables.instance.tmpPath#/#tmpUUID#')>
			<cffile action="read" file="#variables.instance.tmpPath#/#tmpUUID#" variable="returnTXT" />
			<cffile action="delete" file="#variables.instance.tmpPath#/#tmpUUID#" />
		</cfif>
		
		<cfreturn returnTXT />
	</cffunction>

	<cffunction name="diff" access="public" output="No" returntype="string">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0" />
		<cfargument name="diffRevision" required="false" type="numeric" default="0" />
		
		<cfset var argString = '' />
		<cfset var diffURL = '' />
		<cfset var resultData = '' />
		
		<cfif arguments.diffRevision gt 0>
			<cfset diffURL = arguments.svnURL & '@' & arguments.diffRevision />
		</cfif>
		
		<cfif arguments.revision gt 0>
			<cfset arguments.svnURL = arguments.svnURL & '@' & arguments.revision />
		</cfif>
		
		<cfset argString = 'diff --no-auth-cache --force --username #arguments.svnUsername# --password #arguments.svnPassword# #diffURL# #arguments.svnURL#' />
				
		<cfexecute 
			name="#variables.instance.svnBinary#" 
			arguments="#argString#"
			timeout="600" variable="resultData" />

		<cfreturn resultData />	
	</cffunction>
	
</cfcomponent>