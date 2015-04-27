<!--- include main top layout --->
<cfinclude template="../view/layout.top.cfm" />

<cfswitch expression="#listLast(url.event,'.')#">

	<!--- shows main view --->
	<cfcase value="show">
		<cfinclude template="../view/home/index.cfm" />
	</cfcase>
		
</cfswitch>

<!--- include main bottom layout --->
<cfinclude template="../view/layout.bottom.cfm" />