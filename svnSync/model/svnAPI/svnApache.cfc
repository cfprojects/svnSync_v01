<!---
Copyright: Rob Gonda.
Author: Rob Gonda (rob@robgonda.com)
$Id: $

Notes:
Performs svn operations for the apache web engine.
--->

<cfcomponent displayname="SVN Apache Plugin">
	
	<!--- Constructor function --->
	<cffunction name="init" access="public" output="false" returntype="svnApache">
		<cfargument name="os" required="true" type="string" />
		<cfargument name="reposPath" required="true" type="string" />
		<cfargument name="htpasswdBin" required="true" type="string" />
		<cfargument name="apacheBin" required="true" type="string" />
		<cfargument name="apacheConfigFile" required="true" type="string" />
		
		<cfscript>
			variables.instance 					= structNew();
			variables.instance.os				= arguments.os;
			variables.instance.reposPath		= arguments.reposPath;
			variables.instance.htpasswdBin		= arguments.htpasswdBin;
			variables.instance.apacheBin		= arguments.apacheBin;
			variables.instance.apacheConfigFile	= arguments.apacheConfigFile;
		</cfscript>

		<cfreturn this />
	</cffunction>
	
	<cffunction name="addUser" access="public" output="false" returntype="void">
		<cfargument name="repositoryName" type="string" required="true" />
		<cfargument name="username" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		
		<cfscript>
			var repoPath = '#variables.instance.reposPath#\#arguments.repositoryName#';
			var passwordFilePath = '#repoPath#\conf\htpasswd';
			var htpasswdBin = variables.instance.htpasswdBin;
			var createFileBoolean = '';
		</cfscript>
		
		<cfif variables.instance.os neq "Windows">
			<cfset repoPath = replace(repoPath, '\' ,'/' ,'ALL') />
			<cfset passwordFilePath = replace(passwordFilePath, '\' ,'/' ,'ALL') />
		</cfif>
		
		<!--- check if Repo exists --->
		<cfif not directoryExists( repoPath )>
			<cfthrow type="svnApache" message="Error adding user. Repository does not exist" />
		</cfif>
		
		<cfif not len(arguments.username)>
			<cfthrow type="svnApache" message="Error adding user. Username cannot be blank" />
		</cfif>

		<cfif not len(arguments.password)>
			<cfthrow type="svnApache" message="Error adding user. Password cannot be blank" />
		</cfif>

		<!--- check htpassword file exists --->
		<cfif not fileExists( passwordFilePath )>
			<cfset createFileBoolean = 'c' />
		</cfif>

		
		<!--- TODO: remove SUDO and make it Windows Compatible --->
		
		<!--- Try to add user to password file --->
		<cftry>
			<cfexecute name='/usr/bin/sudo' arguments='#htpasswdBin# -#createFileBoolean#mb "#passwordFilePath#" #arguments.userName# #arguments.password#' timeout="30" />
			<cfcatch type="any">
				<cfthrow type="svnAdmin" message="Error creating user: #cfcatch.message#" />
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
			var repoPath = '#variables.instance.reposPath#\#arguments.repositoryName#';
			var passwordFilePath = '#repoPath#\conf\htpasswd';
			var htpasswdBin = variables.instance.htpasswdBin;
			var createFileBoolean = '';
		</cfscript>
		

		<cfif variables.instance.os neq "Windows">
			<cfset repoPath = replace(repoPath, '\' ,'/' ,'ALL') />
			<cfset passwordFilePath = replace(passwordFilePath, '\' ,'/' ,'ALL') />
		</cfif>
		
		<!--- check if Repo exists --->
		<cfif not directoryExists( repoPath )>
			<cfthrow type="svnApache" message="Error removing user. Repository does not exist" />
		</cfif>
		
		<!--- check htpassword file exists --->
		<cfif not fileExists( passwordFilePath )>
			<cfthrow type="svnApache" message="Error removing user. Password file does not exist" />
		</cfif>

		
		<!--- Try to add user to password file --->
		<cftry>
			<cfexecute name='#htpasswdBin#' arguments='-D "#passwordFilePath#" #arguments.userName#' timeout="30" />
			<cfcatch type="any">
				<cfthrow type="svnAdmin" message="Error removing user: #cfcatch.message#" />
			</cfcatch>
		</cftry>
		

	</cffunction>

	<cffunction name="addLocation" access="public" output="false" returntype="void">
		<cfargument name="repo" type="string" required="true" />
		<cfset var newConf = '' />
		
		<cfset var newRepoPath = '#variables.instance.reposPath#\#arguments.repo#' />
		<cfset var newRepoHtpasswdPath = '#newRepoPath#\conf\htpasswd' />

		<cfif variables.instance.os neq "Windows">
			<cfset newRepoPath = replace(newRepoPath, '\' ,'/' ,'ALL') />
			<cfset newRepoHtpasswdPath = replace(newRepoHtpasswdPath, '\' ,'/' ,'ALL') />
		</cfif>

		<cfsavecontent variable="newConf"><cfoutput>
<Location /#arguments.repo#>
	DAV svn
	SVNPath #newRepoPath#

	## initialize basic http authentication
	AuthType Basic
	AuthName "Subversion repository"
	AuthUserFile #newRepoHtpasswdPath#

	## require authentication
	<LimitExcept GET PROPFIND OPTIONS REPORT>
		Require valid-user
	</LimitExcept>	
</Location></cfoutput></cfsavecontent>
		
		<cflock name="svnServiceApacheConfFile" type="EXCLUSIVE" timeout="30" throwontimeout="Yes">
			<cffile action="APPEND" file="#variables.instance.apacheConfigFile#" output="#newConf#" addnewline="No">
		</cflock>
		
	</cffunction>
	
	<cffunction name="removeLocation" access="public" output="false" returntype="void">
		<cfargument name="repo" type="string" required="true" />
		<cfset var currentConf = '' /> <!--- holds existing configuration --->
		<cfset var newConf = '' /> <!--- holds new configuration --->
		<cfset var confStartPos = 0 /> <!--- starting position of location to delete --->
		<cfset var confEndPos = 0 /> <!--- ending position of location to delete --->
		
		<cfset var newRepoPath = '#variables.instance.reposPath#\#arguments.repo#' />
		<cfset var newRepoHtpasswdPath = '#newRepoPath#\conf\htpasswd' />

		<cfif variables.instance.os neq "Windows">
			<cfset newRepoPath = replace(newRepoPath, '\' ,'/' ,'ALL') />
			<cfset newRepoHtpasswdPath = replace(newRepoHtpasswdPath, '\' ,'/' ,'ALL') />
		</cfif>
		
		<cflock name="svnServiceApacheConfFile" type="EXCLUSIVE" timeout="30" throwontimeout="Yes">
			<cffile action="READ" file="#variables.instance.apacheConfigFile#" variable="currentConf">
			<cfset confStartPos = findNoCase("<Location /#arguments.repo#>", currentConf, 1) />
	
			<cfif confStartPos eq 0>
				<cfthrow type="svnApache" message="Error deleting repository: could not find location" />
			</cfif>
			
			<cfset confEndPos = findNoCase("</Location>", currentConf, confStartPos) />
			
			<cfset newConf = removeChars(currentConf, confStartPos, confEndPos - confStartPos + 13) /> <!--- delete until end of location + CR --->
			
			<cffile action="WRITE" file="#variables.instance.apacheConfigFile#" output="#newConf#" addnewline="No">
		</cflock>
		
	</cffunction>

	<cffunction name="restart" access="public" output="false" returntype="void">
		<!--- Try to restart apache --->
		<cftry>
			<cflock name="svnServiceApacheReload" type="EXCLUSIVE" timeout="30" throwontimeout="Yes">
				<cfif variables.instance.os eq "Windows">
					<cfexecute name='#variables.instance.apacheBin#' arguments='-k restart' timeout="30" />
				<cfelse>
					<cfexecute name='#variables.instance.apacheBin#' arguments='restart' timeout="30" />
				</cfif>
			</cflock>
			<cfcatch type="any">
				<cfthrow type="svnAdmin" message="Error restarting apache: #cfcatch.message#" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="reload" access="public" output="false" returntype="void">
		<!--- Try to restart apache --->
		<cfif variables.instance.os eq "Windows">
			<cfthrow type="svnAdmin" message="Error reloading apache: reload function not implemented in Windows Environments" />
		</cfif>
		<cftry>
			<cflock name="svnServiceApacheReload" type="EXCLUSIVE" timeout="30" throwontimeout="Yes">
				<cfexecute name='/usr/bin/sudo' arguments='/sbin/service httpd reload'  /> 
			</cflock>
			<cfcatch type="any">
				<cfthrow type="svnAdmin" message="Error reloading apache: #cfcatch.message#" />
			</cfcatch>
		</cftry>
	</cffunction>


</cfcomponent>