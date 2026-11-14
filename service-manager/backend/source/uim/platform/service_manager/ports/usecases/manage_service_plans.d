/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.ports.usecases.manage_service_plans;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface IManageServicePlans {
  ServicePlan[] listPlans(TenantId tenantId);
  ServicePlan getPlan(TenantId tenantId, ServicePlanId id);
  ServicePlan createPlan(CreateServicePlanRequest request);
  ServicePlan updatePlan(UpdateServicePlanRequest request);
  /// Refused while instances of the plan exist.
  void deletePlan(TenantId tenantId, ServicePlanId id);
}
