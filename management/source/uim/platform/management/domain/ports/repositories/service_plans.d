/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.service_plans;
// import uim.platform.management.domain.entities.service_plan;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Port: outgoing — service plan catalog persistence.
interface ServicePlanRepository : ITenantRepository!(ServicePlan, ServicePlanId) {

  size_t countByService(TenantId tenantId, string serviceName);
  ServicePlan[] findByService(TenantId tenantId, string serviceName);
  void removeByService(TenantId tenantId, string serviceName);

  size_t countByCategory(TenantId tenantId, ServicePlanCategory category);
  ServicePlan[] findByCategory(TenantId tenantId, ServicePlanCategory category);
  void removeByCategory(TenantId tenantId, ServicePlanCategory category);

  size_t countByRegion(TenantId tenantId, string region);
  ServicePlan[] findByRegion(TenantId tenantId, string region);
  void removeByRegion(TenantId tenantId, string region);
  
}
