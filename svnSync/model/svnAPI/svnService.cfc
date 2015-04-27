<!---
Copyright: Rob Gonda.
Author: Rob Gonda (rob@robgonda.com)
$Id: $

Notes:
Service Layer for SVN components.
--->

<cfcomponent>

	<!--- ================ CONSTRUCTOR FUNCTIONS ================ --->
	<cffunction name="init" access="public" output="false" returntype="svnService">
		<cfargument name="configXMLPath" required="true" type="string" hint="relative path to configuration XML" />
		
		<cfset parseConfigXML(arguments.configXMLPath) />
		
		<cfscript>
			variables.com 			= structNew();
			variables.com.svnAdmin	= createObject('component', 'svnAdmin').init(
										os = getConfig('os'),
										reposPath = getConfig('reposPath'),
										svnadminBinary = getConfig('svnadminBinary')
										);
			if ( getConfig('engine') eq 'apache' ) {
				variables.com.engine = createObject('component', 'svnApache').init(
										os = getConfig('os'),
										reposPath = getConfig('reposPath'),
										htpasswdBin = getConfig('htpasswdBin'),
										apacheBin = getConfig('apacheBin'),
										apacheConfigFile = getConfig('apacheConfigFile')
										);
			} else {
				variables.com.engine = createObject('component', 'svnServe').init(
										);
			}
			variables.com.svnClient	= createObject('component', 'svnClient').init(
										svnBinary = getConfig('svnBinary'),
										tmpPath = expandPath(getConfig('tmpPath'))
										);
		</cfscript>
		<cfreturn this />
	</cffunction>
	

	<!--- ================ PUBLIC FUNCTIONS ================ --->

	<cffunction name="exists" access="public" output="No" returntype="boolean">
		<cfargument name="repo" required="Yes" />
		<cfreturn variables.com.svnAdmin.repoExists(arguments.repo) />
	</cffunction>

	<cffunction name="create" access="public" output="true" returntype="void">
		<cfargument name="repo" required="Yes" type="string" />
		<cfargument name="username" required="No" type="string" />
		<cfargument name="passsword" required="no" type="string" />
		
		<cfscript>
			variables.com.svnAdmin.createRepo(arguments.repo);
			
			if ( structKeyExists(arguments, 'USERNAME') and structKeyExists(arguments, 'PASSSWORD') ) {
				variables.com.engine.addUser(arguments.repo, arguments.username, arguments.passsword);
			}
			
			if ( getConfig('engine') eq 'apache' ) {
				variables.com.engine.addLocation(arguments.repo);
				
				if ( getConfig('os') eq 'Windows' ) {
					variables.com.engine.restart();
				} else {
					variables.com.engine.reload();
				}
			}
			
			
		</cfscript>		
	</cffunction>
	
	<cffunction name="delete" access="public" output="No" returntype="void">
		<cfargument name="repo" required="Yes" />
		<cfscript>
			// remove apache repo definition
			if ( getConfig('engine') eq 'apache' ) {
				variables.com.engine.removeLocation(arguments.repo);
			}

			// remove repo folder
			variables.com.svnAdmin.removeRepo(arguments.repo);
			
			// reload apache
			if ( getConfig('os') eq 'Windows' ) {
				variables.com.engine.restart();
			} else {
				variables.com.engine.reload();
			}

		</cfscript>
		<cfreturn  />
	</cffunction>
	
	<cffunction name="addUser" access="public" output="No" returntype="void">
		<cfargument name="repo" required="Yes" type="string" />
		<cfargument name="username" required="Yes" type="string" />
		<cfargument name="passsword" required="Yes" type="string" />

		<cfset variables.com.engine.addUser(arguments.repo, arguments.username, arguments.passsword) />
	</cffunction>

	<cffunction name="listRepos" access="public" output="No" returntype="array">
		<cfreturn variables.com.svnAdmin.listRepos()>
	</cffunction>

	<cffunction name="getLog" access="public" output="No" returntype="query">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0" />

		<cfreturn variables.com.svnClient.getLog( argumentCollection=arguments ) />
	</cffunction>
	
	<cffunction name="getDetailedLog" access="public" output="No" returntype="struct">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0" />

		<cfreturn variables.com.svnClient.getDetailedLog( argumentCollection=arguments ) />
	</cffunction>

	<cffunction name="listFiles" access="public" output="No" returntype="query">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0" />	
		<cfargument name="recursive" required="false" type="boolean" default="false" />

		<cfreturn variables.com.svnClient.list( argumentCollection=arguments ) />
	</cffunction>

	<cffunction name="downloadFile" access="public" output="No" returntype="void">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0" />

		<cfset variables.com.svnClient.download( argumentCollection=arguments ) />
	</cffunction>
	
	<cffunction name="viewFile" access="public" output="No" returntype="string">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0" />

		<cfreturn variables.com.svnClient.view( argumentCollection=arguments ) />
	</cffunction>

	<cffunction name="export" access="public" output="No" returntype="void">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="targetPath" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0" />

		<cfset variables.com.svnClient.export( argumentCollection=arguments ) />
	</cffunction>
	
	<cffunction name="diff" access="public" output="No" returntype="string">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0" />
		<cfargument name="diffRevision" required="false" type="numeric" default="0" />

		<cfreturn variables.com.svnClient.diff( argumentCollection=arguments ) />
	</cffunction>

	<cffunction name="exportZip" access="public" output="No" returntype="void">
		<cfargument name="svnUsername" required="true" type="string" />
		<cfargument name="svnPassword" required="true" type="string" />
		<cfargument name="svnURL" required="true" type="string" />
		<cfargument name="revision" required="false" type="numeric" default="0" />
		<cfargument name="fileName" required="false" type="string" />

		<cfset variables.com.svnClient.exportZip( argumentCollection=arguments ) />
	</cffunction>

	<!--- TODO: Remove this call --->	
	<cffunction name="reload" access="public" output="No" returntype="void">
		<cfreturn variables.com.engine.reload() />
	</cffunction>
	
	
	<!--- ================ PRIVATE FUNCTIONS ================ --->
	
	<cffunction name="parseConfigXML" access="private" output="false" returntype="void">
		<cfargument name="configXMLPath" required="true" type="string" />
		
		<cfset var configXML = '' />
		<cfset var configXMLProperties = '' />
		<cfset var i = 0 />
		
		<!--- initialize config holder --->
		<cfset variables.config = structNew() />
		
		<cfif not FileExists(ExpandPath(arguments.configXMLPath))>
			<cfthrow type="svnAdmin" message="XML Config File Not Found">
		</cfif>
		
		<cftry>
			<cffile action="read" file="#ExpandPath(arguments.configXMLPath)#" variable="configXML">
			<cfcatch type="any">
				<cfthrow type="svnAdmin" message="Error reading XML Config File">
			</cfcatch>
		</cftry>

		<!--- Parse XML --->
		<cftry>
			<cfset configXML = XMLParse(configXML) />
			<cfcatch type="any">
				<cfthrow type="svnAdmin" message="Error parsing XML Config File">
			</cfcatch>
		</cftry>
		
		<cfset configXMLProperties = XMLSearch(configXML, '/configuration/property') />
		<cfloop from="1" to="#arrayLen(configXMLProperties)#" index="i">
			<cfset setConfig(configXMLProperties[i].XmlAttributes.name, configXMLProperties[i].XmlChildren[1].XmlText) />
		</cfloop>

	</cffunction>
	
	<cffunction name="setConfig" access="private" output="false" returntype="void">
		<cfargument name="key" required="true" type="string" />
		<cfargument name="value" required="true" type="string" />
		<cfset variables.config[arguments.key] = arguments.value />
	</cffunction>
	
	<cffunction name="getConfig" access="private" output="false" returntype="string">
		<cfargument name="key" required="true" type="string" />
		<cftry>
			<cfreturn variables.config[arguments.key] />
			<cfcatch type="any">
				<cfthrow type="svnAdmin" message="Cannot find the [#arguments.key#] element in config bean">
			</cfcatch>
		</cftry>
	</cffunction>
	

</cfcomponent>