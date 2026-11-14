/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.ports.repositories.service_instances;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface IServiceInstanceRepository : IEntityRepository!(ServiceInstance, ServiceInstanceId) {
  ServiceInstance findByName(TenantId tenantId, string name);
  ServiceInstance[] findByPlan(TenantId tenantId, ServicePlanId planId);
  ServiceInstance[] findByOffering(TenantId tenantId, ServiceOfferingId offeringId);
  ServiceInstance[] findByPlatform(TenantId tenantId, PlatformId platformId);
}
