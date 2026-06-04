module uim.platform.management.presentation.rest.interfaces.service_plan;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface IServicePlanApi {
    // GET /rest/v1/service_plans
    ServicePlan[] getServicePlans();

    // GET /rest/v1/service_plans/:id
    ServicePlan getServicePlan(string id);
}