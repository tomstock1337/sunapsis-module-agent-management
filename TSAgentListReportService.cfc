<!---
BlankReportService.cfc
iOffice 3.0 | Copyright (c) 2011 Indiana University and Jason Baumgartner

Description: ***

***insert into config table
--->

<cfcomponent extends="AbstractReportService">

	<cffunction name="getReportServiceType" access="package" returntype="ReportServiceType">
		<cfscript>
			reportServiceType = createObject("component", "ReportServiceType");
			reportServiceType.setID("TSAgentListReportService");
			reportServiceType.setReportGroup("TS Reports");
			reportServiceType.setReportName("Agent Listing");
			reportServiceType.setReportDesc("A listing of agents used by the university");
			reportServiceType.setStatistical(true);
			reportServiceType.setOutputXLS(true);
		</cfscript>
		<cfreturn reportServiceType>
  </cffunction>

	<cffunction name="getDataset" access="private" returntype="string">
		<cfargument name="reportObject" type="ReportObject" required="true">
		<cfargument name="options" type="array" required="true">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfquery name="dataQuery">
		SELECT *
			FROM [viewTSAgentList]
			FOR XML PATH
		</cfquery>
		<cfscript>
			content  = getXMLFromQuery(dataQuery);
		</cfscript>

		<cfreturn content>
	</cffunction>


</cfcomponent>