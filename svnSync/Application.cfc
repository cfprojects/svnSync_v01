<cfcomponent displayname="Application" output="false">

	<cfscript>
		this.name = left('svnSync_' & hash(getCurrentTemplatePath()), 32);
		this.clientmanagement = "no";
		this.sessionmanagement = "yes";
		this.sessiontimeout = CreateTimeSpan(0,0,30,0);
		this.setclientcookies = "yes";
	</cfscript>

	<!--- on pplication Start --->
	<cffunction name="onApplicationStart">
		<cfscript>
			// hold application vars
			application.vars = structNew();
			application.vars = createObject( 'component','model.com.environment' ).init( './config/environment.xml' ).getEnvironmentByUrl( CGI.SERVER_NAME );
			// hold components
			application.com = structNew(); 
			application.com.objectFactory = createObject('component','model.objectFactory_app').init();
		</cfscript>
	</cffunction>
	
	
	<!--- on Session Start --->
	<cffunction name="onSessionStart">
	</cffunction>

	
	<!--- on Session End --->
	<cffunction name="onSessionEnd">
	</cffunction>

	
	<!--- on Request Start --->
	<cffunction name="onRequestStart">		
		<cfif structKeyExists(url, "flush") and url.flush eq application.vars.flushPass>
			<cfobjectcache action= "clear">
			<cfset onApplicationStart() />
		</cfif>
	</cffunction>

	
	<!--- on Request End --->
	<cffunction name="onRequestEnd">
	</cffunction>
	
	<!--- on error --->
	<cffunction name="onError">
		<cfset createObject('component','model.com.bugReport').logError(arguments[1]) />
	</cffunction>
	
</cfcomponent>