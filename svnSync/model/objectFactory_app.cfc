<cfcomponent displayname="objectFactory_app" hint="I manage application objects" extends="objectFactory">

	<cffunction name="createObj" access="public" output="No" returntype="any">
		<cfargument name="objName" required="Yes" />
		
		<cfscript>
			switch(arguments.objName) {
				// com
				case "bugReport":
					return createObject('component','com.bugReport');
				break;
				
				case "udf":
					return createObject('component','com.udf').init(this);
				break;
				
				case "diff":
					return createObject('component','com.diff');
				break;
				
				// svnService
				case "svnService":
					return createObject('component','svnAPI.svnService').init(configXMLPath = './model/svnAPI/config.xml');
				break;
				
				// svnSync
				case "syncService":
					return createObject('component','syncService').init(this);
				break;
				
				case "localFileService":
					return createObject('component','localFileService').init(this);
				break;
				
				case "zip":
					return createObject('component','svnAPI.zip');
				break;
			}
		</cfscript>
		
	</cffunction>

</cfcomponent>