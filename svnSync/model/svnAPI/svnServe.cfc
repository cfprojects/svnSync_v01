<!---
Copyright: Rob Gonda.
Author: Rob Gonda (rob@robgonda.com)
$Id: $

Notes:
Performs svn operations for the svnServe engine.
--->

<cfcomponent displayname="SVN Apache Plugin">
	
	<!--- Constructor function --->
	<cffunction name="init" access="public" output="false" returntype="svnServe">
		<cfargument name="configXMLPath" required="true" type="string" hint="relative path to configuration XML" />
		
		<cfset parseConfigXML(arguments.configXMLPath) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="addUser" access="public" output="false" returntype="void">
		<cfargument name="repositoryName" type="string" required="true" />
		<cfargument name="userName" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		
		<cfscript>
			var repoPath = '#getConfig('reposPath')#\#arguments.repositoryName#';
			var passwordFilePath = '#repoPath#\conf\passwd';
			var iniManager = '';
		</cfscript>

		<cfif getConfig('os') neq "Windows">
			<cfset repoPath = replace(repoPath, '\' ,'/' ,'ALL') />
			<cfset passwordFilePath = replace(passwordFilePath, '\' ,'/' ,'ALL') />
		</cfif>
		
		<cfset iniManager = createObject('component','iniManager').init(passwordFilePath) />

		<!--- check if Repo exists --->
		<cfif not directoryExists( repoPath )>
			<cfthrow type="svnServe" message="Error adding user. Repository does not exist" />
		</cfif>
		
		<!--- check htpassword file exists --->
		<cfif not fileExists( passwordFilePath )>
			<cfthrow type="svnServe" message="Error adding user. Password file does not exist" />
		</cfif>

		<!--- Try to add user to password file --->
		<cftry>
			<cfset iniManager.setValue('users', arguments.userName, arguments.password) />
			<cfset iniManager.writeFile() />
			<cfcatch type="any">
				<cfthrow type="svnServe" message="Error creating user: #cfcatch.message#" />
			</cfcatch>
		</cftry>
		

	</cffunction>
	
	<cffunction name="changePassword" access="public" output="false" returntype="void">
		<cfargument name="repositoryName" type="string" required="true" />
		<cfargument name="userName" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		<cfset addUser(arguments.repositoryName, arguments.userName, arguments.password) />
	</cffunction>
	
	<cffunction name="removeUser" access="public" output="false" returntype="void">
		<cfargument name="repositoryName" type="string" required="true" />
		<cfargument name="userName" type="string" required="true" />
		
		<cfscript>
			var repoPath = '#getConfig('reposPath')#\#arguments.repositoryName#';
			var passwordFilePath = '#repoPath#\conf\passwd';
			var iniManager = '';
		</cfscript>
		

		<cfif getConfig('os') neq "Windows">
			<cfset repoPath = replace(repoPath, '\' ,'/' ,'ALL') />
			<cfset passwordFilePath = replace(passwordFilePath, '\' ,'/' ,'ALL') />
		</cfif>
		
		<cfset iniManager = createObject('component','iniManager').init(passwordFilePath) />

		<!--- check if Repo exists --->
		<cfif not directoryExists( repoPath )>
			<cfthrow type="svnServe" message="Error removing user. Repository does not exist" />
		</cfif>
		
		<!--- check htpassword file exists --->
		<cfif not fileExists( passwordFilePath )>
			<cfthrow type="svnServe" message="Error removing user. Password file does not exist" />
		</cfif>

		
		<!--- Try to add user to password file --->
		<cftry>
			<cfset iniManager.removeValue('users', arguments.userName) />
			<cfset iniManager.writeFile() />
			<cfcatch type="any">
				<cfthrow type="svnServe" message="Error removing user: #cfcatch.message#" />
			</cfcatch>
		</cftry>
		

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