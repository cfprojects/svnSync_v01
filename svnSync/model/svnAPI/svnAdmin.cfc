<!---
Copyright: Rob Gonda.
Author: Rob Gonda (rob@robgonda.com)
$Id: $

Notes:
Performs svn adminitration operations.
--->

<cfcomponent displayname="SVN Administrator">
	
	<!--- Constructor function --->
	<cffunction name="init" access="public" output="false" returntype="svnAdmin">
		<cfargument name="os" required="true" type="string" />
		<cfargument name="reposPath" required="true" type="string" />
		<cfargument name="svnadminBinary" required="true" type="string" />
		
		<cfscript>
			variables.instance 					= structNew();
			variables.instance.os				= arguments.os;
			variables.instance.reposPath		= arguments.reposPath;
			variables.instance.svnadminBinary	= arguments.svnadminBinary;
		</cfscript>
		
		<cfreturn this />
	</cffunction>
	
	
	<!--- ================ REPO FUNCTIONS ================ --->

	<cffunction name="listRepos" access="public" output="false" returntype="array" hint="returns array with all repos">
		<cfset var reposQry = '' />
		<cfset var reposArray = arrayNew(1) />
		
		<!--- get all files under repo root --->
		<cfdirectory action="list" directory="#variables.instance.reposPath#" name="reposQry" />
		
		<cfloop query="reposQry">
			<cfif reposQry.type eq "Dir"> <!--- filter folders --->
				<cfset arrayAppend(reposArray, reposQry.name) /> <!--- add to array --->
			</cfif>
		</cfloop>
		
		<!--- return array with all repos --->
		<cfreturn reposArray />
	</cffunction>
	
	<cffunction name="createRepo" access="public" output="false" returntype="void" hint="create a new repository">
		<cfargument name="name" required="true" type="string" />
		
		<cfset var svnAdminBin = '' />
		<cfset var newRepoPath = '#variables.instance.reposPath#\#arguments.name#' />

		<cfif variables.instance.os neq "Windows">
			<cfset newRepoPath = replace(newRepoPath, '\' ,'/' ,'ALL') />
		</cfif>
		
		<!--- check if Repo exists --->
		<cfif repoExists( name )>
			<cfthrow type="svnAdmin" message="Error creating repository. Repository already exists" />
		</cfif>
		
		<!--- Try to create repository --->
		<cftry>
			<cfexecute name='#variables.instance.svnadminBinary#' arguments='create "#newRepoPath#"' timeout="30" />
			<cfcatch type="any">
				<cfthrow type="svnAdmin" message="Error creating repository: #cfcatch.message#" />
			</cfcatch>
		</cftry>
		
		<!--- run chown and chmod --->
		<cfif variables.instance.os neq "Windows">
			<cftry>
				<cfexecute name='/bin/chmod' arguments='-R ug+rwx #newRepoPath#' timeout="30" />
				<cfexecute name='/usr/bin/sudo' arguments='/bin/chown -R rcamden.apache #newRepoPath#' timeout="30" />
				<cfcatch type="any">
					<cfthrow type="svnAdmin" message="Error running chown/chmod: #cfcatch.message#" />
				</cfcatch>
			</cftry>
		</cfif>
		
	</cffunction>
	
	<cffunction name="removeRepo" access="public" output="false" returntype="void" hint="delete a repository">
		<cfargument name="name" required="true" type="string" />
		
		<cfset var repoPath = '#variables.instance.reposPath#\#arguments.name#' />

		<cfif variables.instance.os neq "Windows">
			<cfset repoPath = replace(repoPath, '\' ,'/' ,'ALL') />
		</cfif>
		
		<!--- check if Repo exists --->
		<cfif not repoExists( name )>
			<cfthrow type="svnAdmin" message="Error deleting repository. Repository does not exist" />
		</cfif>
		
		<!--- try to delete repository --->
		<cftry>
			<cfdirectory action="delete" directory="#repoPath#" recurse="true" />
			<cfcatch type="any">
				<cfthrow type="svnAdmin" message="Error deleting repository: #cfcatch.message#" />
			</cfcatch>
		</cftry>
		
	</cffunction>

	<cffunction name="repoExists" access="public" output="false" returntype="boolean">
		<cfargument name="name" required="true" type="string" />

		<cfset var repoPath = '#variables.instance.reposPath#\#arguments.name#' />

		<cfif variables.instance.os neq "Windows">
			<cfset repoPath = replace(repoPath, '\' ,'/' ,'ALL') />
		</cfif>
		
		<!--- check if Repo exists --->
		<cfreturn directoryExists( repoPath ) />
		
	</cffunction>


</cfcomponent>