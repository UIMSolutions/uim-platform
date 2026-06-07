module uim.platform.management.presentation.rest.interfaces.service_plan;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
interface IServicePlanApi {
    // GET /rest/v1/service_plans
    @headerParam("tenantId", "X-Tenant-ID")
    ServicePlan[] getServicePlans(string tenantId);

    // GET /rest/v1/service_plans/:id
    @headerParam("tenantId", "X-Tenant-ID")
    ServicePlan getServicePlan(string tenantId, string id);
}