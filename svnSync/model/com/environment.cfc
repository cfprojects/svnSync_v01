<cfcomponent name="environment" displayname="Environment" hint="Build and Hanldle Environment Specific Application Variables" >
	
	<cffunction name = "init" returntype = "environment" output = "No" hint = "I initialize the component">
		<cfargument name = "xmlFile" type = "string" required = "true"  />
		<cfscript>
			var theFile = '';
		</cfscript>
		
		<cftry>
			<cffile action="read" file="#expandPath( arguments.xmlFile )#" variable="theFile">
			<cfcatch type = "any" >
				<cfthrow type="environment.fileNotFound" message="unable to find xmlFile" />
			</cfcatch>
		</cftry>
		<cfif not isXML( theFile )>
			<cfthrow type="environment.notXml" message="#arguments.xmlFile# is not in valid XML format" />
		</cfif> 
			
		<cfscript>
			variables.instance = structNew();
			variables.instance.environmentXml  	= xmlParse( theFile );
		</cfscript>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name = "getEnvironmentById" access = "public" output = "false" returntype = "struct">
		<cfargument name = "environmentID" type = "string" required = "true"  />
		
		<cfscript>
			var i = 0;
			var propertiesArray = arrayNew(1);
			var properties = structNew();
			var defaultEnvironment = '';
			var defaultPropertiesArray = arrayNew(1);

			properties['environment'] = arguments.environmentId;
			
			defaultEnvironment	= xmlSearch( getXmlFile(), '/environments/default/' );
			selectedElem		= xmlSearch( getXmlFile(), '/environments/environment[@id="#arguments.environmentID#"]/' );
		</cfscript>
		
		<!--- validation --->
		<cfif not arrayLen( selectedElem ) >
			<cfthrow errorcode="environment.emptyArray" message="Attempted to evaluate an empty array of name selectedElem.">
		<cfelseif arrayLen( selectedElem[1].xmlChildren ) lte 1>
			<cfthrow errorcode="environment.missingArrayElement" message="Element 2 does not exists in array of name xmlChildren.">
		</cfif>
		
		<cfscript>
			defaultPropertiesArray = defaultEnvironment[1].XmlChildren[1].XmlChildren;
		
			propertiesArray = selectedElem[1].XmlChildren[2].XmlChildren;

			for( i = 1; i lte arrayLen( defaultPropertiesArray ); i = i+1 ){
				properties[ defaultPropertiesArray[i].XmlAttributes.name ] = trim(defaultPropertiesArray[i].XmlText);
			}
			
			for( i = 1; i lte arrayLen( propertiesArray ); i = i+1 ){
				properties[ propertiesArray[i].XmlAttributes.name ] = trim(propertiesArray[i].XmlText);
			}
		</cfscript>
		
		<cfreturn properties />
	</cffunction>
	
	<cffunction name = "getEnvironmentByUrl" access = "public" output = "false" returntype = "struct">
		<cfargument name = "serverName" type = "string" required = "true"  />
		
		<cfscript>
			var propertiesArray	= arrayNew(1);
			var i = 0;
			var j = 0;
			var environmentUrl = '';
			
			propertiesArray = xmlSearch( getXmlFile(), '/environments/environment' );
		</cfscript>
	
		<cfscript>
			if( isArray( propertiesArray )){
				for(i=1; i lte arrayLen( propertiesArray ); i=i+1){
					if( isArray( propertiesArray[i].xmlChildren )){
					
						for(j=1; j lte arrayLen(propertiesArray[i].xmlChildren); j=j+1 ){
							if( propertiesArray[i].xmlChildren[j].xmlName eq 'patterns'){
								for( k=1; k lte arrayLen( propertiesArray[i].xmlChildren[j].xmlChildren); k=k+1){
									
									environmentUrl = propertiesArray[i].xmlChildren[j].xmlChildren[k].xmlText;
									if( refindnocase( environmentUrl, arguments.serverName ))
										return getEnvironmentById( propertiesArray[i].xmlAttributes.id );
								}
							}
						}
					}	
				}
			}
		</cfscript>
		
		<cfreturn structNew() />
	</cffunction>
	
	<cffunction name = "getXmlFile" access = "private" output = "false" returntype = "xml">
		<cfreturn variables.instance.environmentXml />
	</cffunction>
	
</cfcomponent>