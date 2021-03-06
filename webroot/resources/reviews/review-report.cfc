<cfcomponent extends="taffy.core.resource" taffy:uri="/review/report" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfset dim = objDates.setDim({date=now()}) />


		<cfquery datasource="startfly" result="qResult">
		UPDATE reviews SET 
		tagged = 0, 
		reported = 1,
		dateReported = #dim.dateID#,
		reportComment = '#arguments.reportComment#'
		WHERE reviews.sID = '#arguments.reviewID#'
		</cfquery>

		<cfset result['data'] = arguments />

		<cfset objTools.runtime('post', '/review/report', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
