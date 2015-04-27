<!---
Copyright: Rob Gonda.
Author: Rob Gonda (rob@robgonda.com)
$Id: $

Notes:
ini files manager used by svnServe.cfc.
--->

<cfcomponent>

	<!--- ========= CONSTRUCTOR FUNCTION ============= --->

	<cffunction name="init" access="public" output="false" returntype="iniManager">
		<cfargument name="iniFile" required="false" type="string" hint="location of INI file" />
		<cfargument name="commentChr" required="false" type="string" default="##">
		
		<cfscript>
			variables.instance = structNew();
			variables.instance.commentChr = arguments.commentChr;
			if (structKeyExists(arguments, 'iniFile')) {
				readFile(arguments.iniFile);
			}
		</cfscript>
		
		<cfreturn this />
	</cffunction>


	<!--- ========= SECTION FUNCTIONS ============= --->
	
	<cffunction name="getSections" access="public" output="false" returntype="string">
		<cfif not structKeyExists(variables.instance,'configStruct')>
			<cfthrow type="iniManager" message="Error in [getSections]. File not loaded/parsed" />
		</cfif>

		<cfreturn structKeyList(variables.instance.configStruct) />
	</cffunction>
	
	<cffunction name="addSection" access="public" output="false" returntype="void">
		<cfargument name="section" type="string" required="true" />

		<cfif not structKeyExists(variables.instance,'configStruct')>
			<cfthrow type="iniManager" message="Error in [addSection]. File not loaded/parsed" />
		</cfif>
		<cfif structKeyExists(variables.instance.configStruct, arguments.section)>
			<cfthrow type="iniManager" message="Error in [addSection]. Section already exists" />
		</cfif>
		
		<cfset variables.instance.configStruct[arguments.section] = structNew() />
	</cffunction>

	<cffunction name="removeSection" access="public" output="false" returntype="void">
		<cfargument name="section" type="string" required="true" />

		<cfif not structKeyExists(variables.instance,'configStruct')>
			<cfthrow type="iniManager" message="Error in [removeSection]. File not loaded/parsed" />
		</cfif>
		<cfif not structKeyExists(variables.instance.configStruct, arguments.section)>
			<cfthrow type="iniManager" message="Error in [removeSection]. Section does not exist" />
		</cfif>
		
		<cfset structDelete(variables.instance.configStruct, arguments.section) />
	</cffunction>


	<!--- ========= KEY FUNCTIONS ============= --->

	<cffunction name="getKeyPairs" access="public" output="false" returntype="struct">
		<cfargument name="section" type="string" required="true" />

		<cfif not structKeyExists(variables.instance,'configStruct')>
			<cfthrow type="iniManager" message="Error in [getKeyPairs]. File not loaded/parsed" />
		</cfif>
		<cfif not structKeyExists(variables.instance.configStruct, arguments.section)>
			<cfthrow type="iniManager" message="Error in [getKeyPairs]. Section does not exist" />
		</cfif>

		<cfreturn variables.instance.configStruct[arguments.section] />
	</cffunction>

	<cffunction name="getKeys" access="public" output="false" returntype="string">
		<cfargument name="section" type="string" required="true" />

		<cfif not structKeyExists(variables.instance,'configStruct')>
			<cfthrow type="iniManager" message="Error in [getKeys]. File not loaded/parsed" />
		</cfif>
		<cfif not structKeyExists(variables.instance.configStruct, arguments.section)>
			<cfthrow type="iniManager" message="Error in [getKeys]. Section does not exist" />
		</cfif>

		<cfreturn structKeyList(variables.instance.configStruct[arguments.section]) />
		
	</cffunction>

	<cffunction name="removeKey" access="public" output="false" returntype="void">
		<cfargument name="section" type="string" required="true" />
		<cfargument name="key" type="string" required="true" />

		<cfif not structKeyExists(variables.instance,'configStruct')>
			<cfthrow type="iniManager" message="Error in [removeKey]. File not loaded/parsed" />
		</cfif>
		<cfif not structKeyExists(variables.instance.configStruct, arguments.section)>
			<cfthrow type="iniManager" message="Error in [removeKey]. Section does not exist" />
		</cfif>
		<cfif not structKeyExists(variables.instance.configStruct[arguments.section], arguments.key)>
			<cfthrow type="iniManager" message="Error in [removeKey]. Key does not exist" />
		</cfif>
		
		<cfset structDelete(variables.instance.configStruct[arguments.section], arguments.key) />
	</cffunction>

	<!--- ========= VALUE FUNCTIONS ============= --->
	
	<cffunction name="getValue" access="public" output="false" returntype="string">
		<cfargument name="section" type="string" required="true" />
		<cfargument name="key" type="string" required="true" />

		<cfif not structKeyExists(variables.instance,'configStruct')>
			<cfthrow type="iniManager" message="Error in [getValue]. File not loaded/parsed" />
		</cfif>
		<cfif not structKeyExists(variables.instance.configStruct, arguments.section)>
			<cfthrow type="iniManager" message="Error in [getValue]. Section does not exist" />
		</cfif>
		<cfif not structKeyExists(variables.instance.configStruct[arguments.section], arguments.key)>
			<cfthrow type="iniManager" message="Error in [getValue]. Key does not exist" />
		</cfif>

		<cfreturn variables.instance.configStruct[arguments.section][arguments.key] />
	
	</cffunction>
	
	<cffunction name="setValue" access="public" output="false" returntype="void">
		<cfargument name="section" type="string" required="true" />
		<cfargument name="key" type="string" required="true" />
		<cfargument name="value" type="string" required="true" />

		<cfif not structKeyExists(variables.instance,'configStruct')>
			<cfthrow type="iniManager" message="Error in [setValue]. File not loaded/parsed" />
		</cfif>
		<cfif not structKeyExists(variables.instance.configStruct, arguments.section)>
			<cfthrow type="iniManager" message="Error in [setValue]. Section does not exist" />
		</cfif>

		<cfset variables.instance.configStruct[arguments.section][arguments.key] = arguments.value />
	</cffunction>

	<cffunction name="removeValue" access="public" output="false" returntype="void">
		<cfargument name="section" type="string" required="true" />
		<cfargument name="key" type="string" required="true" />

		<cfif not structKeyExists(variables.instance,'configStruct')>
			<cfthrow type="iniManager" message="Error in [removeValue]. File not loaded/parsed" />
		</cfif>
		<cfif not structKeyExists(variables.instance.configStruct, arguments.section)>
			<cfthrow type="iniManager" message="Error in [removeValue]. Section does not exist" />
		</cfif>
		<cfif not structKeyExists(variables.instance.configStruct[arguments.section], arguments.key)>
			<cfthrow type="iniManager" message="Error in [removeValue]. Key does not exist" />
		</cfif>

		<cfset structDelete(variables.instance.configStruct[arguments.section], arguments.key) />
	</cffunction>

	<!--- ========= MISC FUNCTIONS ============= --->

	<cffunction name="clear" access="public" output="false" returntype="void">
		<cfset variables.instance.configStruct = structNew() />
	</cffunction>

	<cffunction name="getMemento" access="public" output="false" returntype="struct">
		<cfif not structKeyExists(variables.instance,'configStruct')>
			<cfthrow type="iniManager" message="Error in [getSections]. File not loaded/parsed" />
		</cfif>

		<cfreturn variables.instance.configStruct />
	</cffunction>
	
	<cffunction name="setMemento" access="public" output="false" returntype="void">
		<cfargument name="memento" type="struct" required="true" />

		<cfset variables.instance.configStruct = arguments.memento />
	</cffunction>

	<!--- ========= FILE FUNCTIONS ============= --->
	
	<cffunction name="writeFile" access="public" output="false" returntype="void">
		<cfset var sections = getSections() />
		<cfset var section = '' />
		<cfset var keys =  '' />
		<cfset var key =  '' />
		<cfset var newline = chr(10) />
		<cfset var fileContent = variables.instance.commentSection />
		
		<cfif len(fileContent)>
			<cfset fileContent = fileContent & newline />
		</cfif>
		<cfloop list="#sections#" index="section">
			<cfset fileContent = fileContent & "[#section#]" & newline />
			<cfset keys = getKeys(section) />
			<cfloop list="#keys#" index="key">
				<cfset fileContent = fileContent & "#key# = " & getValue(section,key) & newline />
			</cfloop>
			<cfset fileContent = fileContent & newline />
		</cfloop>
		
		<cffile action="write" file="#variables.instance.fileLocation#" output="#fileContent#" addnewline="false" />
		
	</cffunction>
	
	<cffunction name="readFile" access="public" output="false" returntype="void">
		<cfargument name="iniFile" required="true" type="string" hint="location of INI file" />
		
		<cfset var iniFineContent = '' />

		<cfif fileExists(arguments.iniFile)>
			<cfset variables.instance.fileLocation = arguments.iniFile />
		<cfelse>
			<cfset variables.instance.fileLocation = expandPath(arguments.iniFile) />
		</cfif>
		
		<cfif not fileExists(variables.instance.fileLocation)>
			<cfthrow type="iniManager" message="Cannot find specified file [#variables.instance.fileLocation#]" />
		</cfif>

		<cffile action="read" file="#variables.instance.fileLocation#" variable="iniFineContent" />
		
		<cfset parseFile(iniFineContent) />
	</cffunction>

	<!--- ========= PRIVATE FUNCTIONS ============= --->
	
	
	<cffunction name="parseFile" access="private" output="false" returntype="void">
		<cfargument name="iniFineContent" type="string" required="true" />

		<cfset var line = '' />
		<cfset var lastStruct = '' />
		<cfset variables.instance.commentSection = '' />
		
		<cfset clear() />		
		
		<cfloop list="#iniFineContent#" delimiters="#chr(10)#" index="line">
			<cfset line = trim(line) />
			<cfif not len(line)>
				<!--- ignore empty line --->
			<cfelseif not len(lastStruct) and left(line,1) eq variables.instance.commentChr>
				<!--- comment section --->
				<cfset variables.instance.commentSection = variables.instance.commentSection & line & chr(10) />
			<cfelseif left(line,1) eq '[' and right(line,1) eq ']'>
				<cfset lastStruct = mid(line,2,len(line)-2) />
				<cfset addSection(lastStruct) />
			<cfelse>
				<cfset setValue(lastStruct, trim(listGetAt(line,1,'=')), trim(listGetAt(line,2,'='))) />
			</cfif>
		</cfloop>
		
	</cffunction>
	
</cfcomponent>