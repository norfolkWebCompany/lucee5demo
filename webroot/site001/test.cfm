<cfoutput>
<p>Hello Viewer #now()#</p>
</cfoutput>

<cfquery name="myQuery" datasource="heroku_17a6a798d69ee70">
SELECT * FROM first
</cfquery>
<cfdump var="#MyQuery#"/>

<cfscript>
	dump( application );
	dump( cgi );
	dump( client );
	dump( server );
</cfscript>