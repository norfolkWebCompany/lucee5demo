<p>Hello Brother</p>

<cfquery name="q1" datasource="heroku_17a6a798d69ee70">
SELECT * FROM first
</cfquery>
<cfdump var="#q1#"/>

<cfscript>
	dump( application );
	dump( cgi );
	dump( client );
	dump( server );
</cfscript>
