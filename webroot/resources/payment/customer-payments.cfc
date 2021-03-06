<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/payments" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="customerID" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />
		<cfset result['arguments'] = arguments />

		<cfif isDefined("arguments.startDate") and arguments.startDate neq ''>
			<cfset sDate = objTools.cfDateFromJSON(arguments.startDate) />
			<cfset sDate = objTools.rootDay(sDate) />
			<cfset sDateSQL = 'AND paymentsIn.rootDay >= ' & #sDate# />
		<cfelse>
			<cfset sDateSQL = '' />
		</cfif>

		<cfif isDefined("arguments.endDate") and arguments.endDate neq ''>
			<cfset eDate = objTools.cfDateFromJSON(arguments.endDate) />
			<cfset eDate = objTools.rootDay(eDate) />
			<cfset eDateSQL = 'AND payments.rootDay <= ' & #eDate# />
		<cfelse>
			<cfset eDateSQL = '' />
		</cfif>


		<cfif isDefined("arguments.daysFromNow") and arguments.daysFromNow neq ''>
			<cfset sDate = objTools.rootDay(now()) />
			<cfset sDateSQL = 'AND paymentsIn.rootDay >= ' & #sDate# />
			<cfset eDate = objTools.rootDay(dateAdd('d',arguments.daysFromNow,now())) />
			<cfset eDateSQL = 'AND payments.rootDay <= ' & #eDate# />
		</cfif>



		<cfquery name="totalRecords" datasource="startfly">
		SELECT COUNT(*) AS totalRecs
		FROM paymentsIn 
		INNER JOIN listing ON paymentsIn.listingID = listing.ID 
		INNER JOIN partner ON paymentsIn.partnerID = partner.ID 
		INNER JOIN locations ON listing.location = locations.ID
		WHERE paymentsIn.customerID = #internalCustomerID# 
		#sDateSQL#
		#eDateSQL#
		</cfquery>

		<cfset result['pagination']['totalRecords'] = totalRecords.totalRecs />
		<cfset result['pagination']['pages'] = ceiling(totalRecords.totalRecs / arguments.pagination.limit) />

		<cfquery name="payments" datasource="startfly" result="qResult">
		SELECT 
		paymentsIn.sID AS paymentSID,
		paymentsIn.amount,
		paymentsIn.created,
		listing.sID AS listingSID,
		listing.name AS listingName,
		listing.location,
		listing.type,
		locations.name AS locationName,
		partner.sID AS partnerSID,
		partner.firstName,
		partner.surname,
		partner.nickname,
		partner.company
		FROM paymentsIn 
		INNER JOIN listing ON paymentsIn.listingID = listing.ID 
		INNER JOIN partner ON paymentsIn.partnerID = partner.ID 
		INNER JOIN locations ON listing.location = locations.ID
		WHERE paymentsIn.customerID = #internalCustomerID# 
		#sDateSQL#
		#eDateSQL#
		ORDER BY #arguments.orderBy.sortField# 
		<cfif arguments.orderBy.doReverse> 
		DESC
		</cfif>
		LIMIT #((arguments.pagination.currentPage * arguments.pagination.limit)-arguments.pagination.limit)#, #arguments.pagination.limit#
		</cfquery>


		<cfset result['query'] = qResult />


			<cfset dataArray = arrayNew(1) />

			<cfif payments.recordCount gt 0>

				<cfloop query="payments">
					
		
					<cfset dataArray[payments.currentRow]['paymentID'] = payments.paymentSID />
					<cfset dataArray[payments.currentRow]['amount'] = payments.amount />
					<cfset dataArray[payments.currentRow]['listingID'] = payments.listingSID />
					<cfset dataArray[payments.currentRow]['listingName'] = payments.listingName />
					<cfset dataArray[payments.currentRow]['listingType'] = payments.type />
					<cfset dataArray[payments.currentRow]['date'] = dateFormat(payments.created, "yyyy-mm-dd") & 'T' & timeFormat(payments.created,"HH:mm:ss") & 'Z' />
					<cfset dataArray[payments.currentRow]['location']['locationID'] = payments.location />
					<cfset dataArray[payments.currentRow]['location']['name'] = payments.locationName />
					<cfset dataArray[payments.currentRow]['partner']['partnerID'] = payments.partnerSID />
					<cfset dataArray[payments.currentRow]['partner']['firstname'] = payments.firstname />
					<cfset dataArray[payments.currentRow]['partner']['surname'] = payments.surname />
					<cfset dataArray[payments.currentRow]['partner']['nickname'] = payments.nickname />
					<cfset dataArray[payments.currentRow]['partner']['company'] = payments.company />

				</cfloop>

				<cfset result['data'] = dataArray />

			<cfelse>
				<cfset result['status']['statusCode'] = 500 />
				<cfset result['status']['message'] = 'Unable to locate data record' />
			</cfif>

			<cfset objTools.runtime('get', '/customer/{customerID}/payments', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
