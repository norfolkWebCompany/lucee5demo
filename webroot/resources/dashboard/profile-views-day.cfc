<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/dashboard/profile" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset dim = objDates.setDim({date=now()}) />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset endDay = dim.dateID />
		<cfset startDay = dim.dateID - 6 />


		<cfset labels = arrayNew(1) />
		<cfset data = arrayNew(1) />
		<cfset series = arrayNew(1) />

		<cfset countData = arrayNew(1) />

		<cfloop index="y" from="#startDay#" to="#endDay#">

			<cfquery name="q" datasource="startfly">
			SELECT 
			IFNULL(sum(partnerViews.views), 0) AS total
			FROM partnerViews 
			WHERE partnerViews.dateID = #y#
			AND partnerViews.partnerID = #internalPartnerID#
			</cfquery>

			<cfset dateToday = objDates.getDim(y,0) />

			<cfset labels[arrayLen(labels) + 1] =  dateFormat(dateToday,'dd/mm/yyyy') /> 

			<cfset countData[arrayLen(countData) + 1] = q.total />

		</cfloop>

		<cfset series[1] = 'Count' />

		<cfset result['data']['labels'] = labels />
		<cfset result['data']['data'] = arrayNew(1) />
		<cfset arrayAppend(result['data']['data'],countData) />
		<cfset result['data']['series'] = series />

		<cfset result['data']['totalsPeriod']['count'] = arraySum(countData) />

		<cfquery name="qYear" datasource="startfly">
		SELECT 
		IFNULL(sum(partnerViews.views), 0) AS total
		FROM partnerViews 
		LEFT JOIN dimDate ON partnerViews.dateID = dimDate.dateID 
		WHERE dimDate.year = #year(now())# 
		AND partnerViews.partnerID = #internalPartnerID#
		</cfquery>

		<cfquery name="qMonth" datasource="startfly">
		SELECT 
		IFNULL(sum(partnerViews.views), 0) AS total
		FROM partnerViews 
		LEFT JOIN dimDate ON partnerViews.dateID = dimDate.dateID 
		WHERE dimDate.year = #year(now())# 
		AND dimDate.month = #month(now())#
		AND partnerViews.partnerID = #internalPartnerID#
		</cfquery>


		<cfset result['data']['totalsYear']['count'] = qYear.total />
		<cfset result['data']['totalsMonth']['count'] = qMonth.total />

			<cfset objTools.runtime('get', '/partner/{partnerID}/dashboard/profile', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
