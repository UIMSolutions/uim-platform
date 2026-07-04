/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.service_plans;

// import uim.platform.management.domain.entities.service_plan;
// import uim.platform.management.domain.ports.repositories.service_plans;

//  

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemoryServicePlanRepository : TenantRepository!(ServicePlan, ServicePlanId), ServicePlanRepository {
  // TODO: mixin TenantRepositoryTemplate!(MemoryServicePlanRepository, ServicePlan, ServicePlanId);

  // #region ByService
  size_t countByService(TenantId tenantId, string serviceName) {
    return findByService(tenantId, serviceName).length;
  }

  ServicePlan[] filterByService(ServicePlan[] items, string serviceName) {
    return items.filter!(e => e.serviceName == serviceName).array;
  }

  ServicePlan[] findByService(TenantId tenantId, string serviceName) {
    return filterByService(findByTenant(tenantId), serviceName);
  }

  void removeByService(TenantId tenantId, string serviceName) {
    findByService(tenantId, serviceName).each!(e => remove(e));
  }
  // #endregion ByService

  // #region ByCategory
  size_t countByCategory(TenantId tenantId, ServicePlanCategory category) {
    return findByCategory(tenantId, category).length;
  }

  ServicePlan[] filterByCategory(ServicePlan[] items, ServicePlanCategory category) {
    return items.filter!(e => e.category == category).array;
  }

  ServicePlan[] findByCategory(TenantId tenantId, ServicePlanCategory category) {
    return filterByCategory(findByTenant(tenantId), category);
  }

  void removeByCategory(TenantId tenantId, ServicePlanCategory category) {
    findByCategory(tenantId, category).each!(e => remove(e));
  }
  // #endregion ByCategory

  // #region ByRegion
  size_t countByRegion(TenantId tenantId, string region) {
    return findByRegion(tenantId, region).length;
  }

  ServicePlan[] filterByRegion(ServicePlan[] items, string region) {
    return items.filter!(e => e.availableRegions.canFind(region)).array;
  }

  ServicePlan[] findByRegion(TenantId tenantId, string region) {
    return filterByRegion(findByTenant(tenantId), region);
  }

  void removeByRegion(TenantId tenantId, string region) {
    findByRegion(tenantId, region).each!(e => remove(e));
  }
  // #endregion ByRegion

}
///
unittest {
  auto repo = new MemoryServicePlanRepository();

  auto tenantId = TenantId("tenant1");
  auto servicePlanId = ServicePlanId("plan1");
  auto servicePlan = ServicePlan(tenantId);
  servicePlan.id = servicePlanId;
  servicePlan.serviceName = "Service 1";
  servicePlan.category = ServicePlanCategory.service;
  servicePlan.availableRegions = ["region1", "region2"];

  repo.save(servicePlan);

  assert(repo.countByService(tenantId, "Service 1") == 1);
  assert(repo.findByService(tenantId, "Service 1").length == 1);
  assert(repo.findByService(tenantId, "Service 1")[0].id == servicePlanId); 
  
  repo.removeByService(tenantId, "Service 1");
  assert(repo.countByService(tenantId, "Service 1") == 0);
  assert(repo.countByCategory(tenantId, ServicePlanCategory.service) == 0);
  assert(repo.countByRegion(tenantId, "region1") == 0);
}