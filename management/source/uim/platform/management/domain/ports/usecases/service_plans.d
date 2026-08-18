/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.usecases.service_plans;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage the service plan catalog.
interface IManageServicePlansUseCase {

  UsecaseResult createPlan(CreateServicePlanRequest req);
  UsecaseResult updatePlan(UpdateServicePlanRequest req);
  ServicePlan getPlan(TenantId tenantId, ServicePlanId id);
  ServicePlan[] listPlans(TenantId tenantId);
  ServicePlan[] listPlansByService(TenantId tenantId, string serviceName);
  ServicePlan[] listPlansByCategory(TenantId tenantId, string category);
  ServicePlan[] listPlansByRegion(TenantId tenantId, string region);
  UsecaseResult deletePlan(TenantId tenantId, ServicePlanId id);

}
