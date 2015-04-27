<cfcomponent displayname="udf" hint="I hold multiple udfs">

	<cffunction name="init" access="public" output="No" returntype="udf">
		<cfargument name="objectFactory" required="Yes" />
	
		<cfscript>
			// hold instance		
			variables.instance = structNew();
		</cfscript>

		<cfreturn this />
	</cffunction>

	<cffunction name="cfdump" returntype="void" output="Yes">
		<cfargument name="d">
		<cfdump var="#d#">
	</cffunction>
	
	<cffunction name="cflocation" returntype="void" output="No">
		<cfargument name="d">
		<cflocation addtoken="No" url="#d#">
	</cffunction>
	
	<cffunction name="cfcookie" returntype="void" output="No">
		<cfargument name="n">
		<cfargument name="v">
		<cfcookie name="#n#" value="#v#" />
	</cffunction>
	
	<cffunction name="cfparam" returntype="void" output="No">
		<cfargument name="p">
		<cfargument name="d">
		<cfparam name="#p#" default="#d#">
	</cffunction>
	
	<cffunction name="cfabort" returntype="void" output="No">
		<cfabort />
	</cffunction>	
	
	<cffunction name="throw" access="public" returnType="void" output="false" hint="Throws errors.">
		<cfargument name="message" type="string" required="false" default="">
		<cfargument name="type" type="string" required="false" default="custom">
		<cfthrow type="#arguments.type#" message="#arguments.message#">
	</cffunction>

	<cffunction name="rewritePath" access="public" output="false" returntype="string">
		<cfargument name="path" required="true" type="string" default="" />
		<cfargument name="type" required="false" type="string" default="dir" />
	
		<cfset var pathPrefix = '' />

		<cfif len(arguments.path)>
			<cfset arguments.path = replace(arguments.path,'\','/','all') />

			<cfif arguments.path neq '/'>
				<cfif left(arguments.path,2) eq '//'>
					<cfset pathPrefix = '//' />
					<cfset arguments.path = right(arguments.path,len(arguments.path)-2) />
				<cfelseif find(left(arguments.path,3),':/')>
					<cfset pathPrefix = left(arguments.path,3) />
					<cfset arguments.path = right(arguments.path,len(arguments.path)-3) />
				</cfif>
				
				<cfloop condition="find('//',arguments.path) or find('\',arguments.path)">
					<cfset arguments.path = replace(arguments.path,'\','/','all') />
					<cfset arguments.path = replace(arguments.path,'//','/','all') />
				</cfloop>
			
				<cfif len(arguments.path) gt 1>			
					<cfif type eq 'dir' and right(arguments.path,1) neq '/'>			
						<cfset arguments.path = arguments.path & '/' />
					<cfelseif type eq 'file' and right(arguments.path,1) eq '/'>
						<cfset arguments.path = left(arguments.path,len(arguments.path)-1) />
					</cfif>
					
					<cfif left(arguments.path,1) eq '/'>
						<cfset arguments.path = right(arguments.path,len(arguments.path)-1) />
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		<cfset arguments.path = pathPrefix & arguments.path />
		
		<cfreturn arguments.path />
	</cffunction>
	
	<cffunction name="rewriteURL" access="public" output="false" returntype="string">
		<cfargument name="path" required="true" type="string" default="" />
		<cfargument name="type" required="false" type="string" default="dir" />
		
		<cfset var urlPrefix = '' />
		
		<cfif len(arguments.path)>
			<cfif findNoCase('http://',arguments.path)>
				<cfset urlPrefix = 'http://' />
			<cfelseif findNoCase('https://',arguments.path)>
				<cfset urlPrefix = 'https://' />
			<cfelseif findNoCase('svn://',arguments.path)>
				<cfset urlPrefix = 'svn://' />
			</cfif>
			
			<cfset arguments.path = replace(arguments.path,urlPrefix,'') />
			
			<cfif len(arguments.path)>
				<cfloop condition="find('\',arguments.path) or find('//',arguments.path)">
					<cfset arguments.path = replace(arguments.path,'\','/','all') />
					<cfset arguments.path = replace(arguments.path,'//','/','all') />
				</cfloop>
			
				<cfif len(arguments.path) gt 1>			
					<cfif left(arguments.path,1) eq '/'>
						<cfset arguments.path = right(arguments.path,len(arguments.path)-1) />
					</cfif>
				</cfif>
				
				<cfif type eq 'dir' and right(arguments.path,1) neq '/'>			
					<cfset arguments.path = arguments.path & '/' />
				<cfelseif type eq 'file' and right(arguments.path,1) eq '/'>
					<cfset arguments.path = left(arguments.path,len(arguments.path)-1) />
				</cfif>
			</cfif>
		</cfif>
	
		<cfset arguments.path = urlPrefix & arguments.path />

		<cfreturn arguments.path />
	</cffunction>
</cfcomponent>