<cfsilent>
	<cfset udf = application.com.objectFactory.getInstance('udf') />
	
	<!--- merge event from form scope to url --->
	<cfif not structKeyExists(url,'event') and structKeyExists(form,'event')>
		<cfset url.event = form.event />
	</cfif>

	<!--- default event --->
	<cfparam name="url.event" default="#application.vars.defaultEvent#" />
	<cfparam name="url.layout" default="default" />
	
	<cfsetting showdebugoutput="#application.vars.showDebug#" />
</cfsilent>

<!--- open layout --->
<cfinclude template="./layout/#url.layout#.top.cfm" />
<!--- call controller --->
<cfinclude template="./controller/#listfirst(url.event, '.')#.cfm" />
<!--- close layout --->
<cfinclude template="./layout/#url.layout#.bottom.cfm" />