<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/qualifications" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="q" datasource="startfly">
		SELECT 
		qualifications.ID,
		qualifications.name
		FROM qualifications 
		WHERE qualifications.status = 1 
		ORDER BY qualifications.sortOrder, qualifications.name
		</cfquery>


		<cfset dataArray = arrayNew(1) />

		<cfloop query="q">
			
			<cfset dataArray[q.currentRow]['ID'] = q.ID />
			<cfset dataArray[q.currentRow]['name'] = q.name />

		</cfloop>


		<cfset result['data'] = dataArray />


		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>

</cfcomponent>
