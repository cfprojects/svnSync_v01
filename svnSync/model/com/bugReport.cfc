<cfcomponent>
	<cffunction name="init" access="public" output="No" returntype="bugReport">
		<cfreturn this />
	</cffunction>
	
	<!--- creates and logs bug report --->
	<cffunction name="logError" access="public" output="No" returntype="struct">
		<cfargument name="errorStruct" required="Yes" type="any" />
		<cfset var errorDetail = '' />
		
		<cfsavecontent variable="errorDetail">
			<cfoutput>
				<div style="font-size:12px;font-family:Arial;text-align:left;">
					<h3>BUG REPORT - #application.vars.environment# - #application.applicationname# - #arguments.errorStruct.type# - #arguments.errorStruct.message#</h3>
					<strong>Date:</strong> #dateformat(now(), "MM/DD/YYYY")# #timeformat(now(),"hh:MM:SS TT")#
					<br />
					<strong>Environemnt:</strong> #application.vars.environment#
					<br />
					<strong>Application Name:</strong> #application.applicationname#
					<br />
					<strong>Server Name:</strong> #CGI.CF_TEMPLATE_PATH#
					<br />
					<strong>HTTP Host:</strong> #cgi.http_host# 
					<br />
					<strong>Template:</strong> #cgi.script_name#
					<br />
					<strong>Query String:</strong> #cgi.QUERY_STRING#
					<br />
					<strong>Path Info:</strong> #cgi.PATH_INFO# - #CGI.PATH_TRANSLATED#
					<br />
					<strong>Referrer:</strong> #cgi.HTTP_REFERER#
					<br />
					<strong>User Agent:</strong> #cgi.HTTP_USER_AGENT#
					<br />
					<br />
					<cfdump var="#arguments.errorStruct#" label="error"><br />
					<cfdump var="#form#" label="form"><br />
					<cfdump var="#url#" label="url"><br />
					<cfdump var="#cgi#" label="cgi"><br />
					<cfdump var="#session#" label="session"><br />
					<cfif isDefined('flash')>
						<cfdump var="#flash#" label="flash">
					</cfif>
				</div>
			</cfoutput>
		</cfsavecontent>

		<!--- display error page --->		
		<cfswitch expression="#application.vars.environment#">
			<cfcase value="DEV,STAGING,PRODUCTION">
				<!--- send report to bugLog --->
				<cfparam name="session.cfid" default="" />
				<cfparam name="session.cftoken" default="" />
				<cfif len(application.vars.bugLogWSDL)>
					<cfinvoke webservice="#application.vars.bugLogWSDL#" method="logEntry" returnvariable="bBugLog">
						<cfinvokeargument name="dateTime" value="#now()#" />
						<cfinvokeargument name="message" value="#arguments.errorStruct.message#" />
						<cfinvokeargument name="applicationCode" value="#application.applicationname#" />
						<cfinvokeargument name="severityCode" value="error" />
						<cfinvokeargument name="hostName" value="#cgi.http_host#" />
						<cfinvokeargument name="exceptionMessage" value="#arguments.errorStruct.message#" />
						<cfinvokeargument name="exceptionDetails" value="#arguments.errorStruct.detail#" />
						<cfinvokeargument name="CFID" value="#session.cfid#" />
						<cfinvokeargument name="CFTOKEN" value="#session.cftoken#" />
						<cfinvokeargument name="userAgent" value="#cgi.HTTP_USER_AGENT#" />
						<cfinvokeargument name="templatePath" value="#cgi.script_name#" />
						<cfinvokeargument name="HTMLReport" value="#errorDetail#" />
					</cfinvoke>
				</cfif>
				<cfset getPageContext().forward("../../view/error.cfm") />
			</cfcase>
			<cfdefaultcase>
				<cfoutput>#errorDetail#</cfoutput>
				<cfabort>
			</cfdefaultcase>
		</cfswitch>		
	</cffunction>
	
</cfcomponent>