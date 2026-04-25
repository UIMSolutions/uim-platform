/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.service_plans;

// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.service_plan;
// import uim.platform.management.domain.ports.repositories.service_plans;

// // import std.algorithm : filter, canFind;
// // import std.array : array;

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemoryServicePlanRepository : IdRepository!(ServicePlan, ServicePlanId), ServicePlanRepository {
  // TODO: mixin TenantRepositoryTemplate!(MemoryServicePlanRepository, ServicePlan, ServicePlanId);

  // #region ByService
  size_t countByService(string serviceName) {
    return findByService(serviceName).length;
  }

  ServicePlan[] filterByService(ServicePlan[] items, string serviceName) {
    return items.filter!(e => e.serviceName == serviceName).array;
  }

  ServicePlan[] findByService(string serviceName) {
    return findAll().filterByService(serviceName).array;
  }

  void removeByService(string serviceName, bool deleteTenantIfEmpty = false) {
    findByService(serviceName).removeAll(deleteTenantIfEmpty);
  }
  // #endregion ByService

  // #region ByCategory
  size_t countByCategory(ServicePlanCategory category) {
    return findByCategory(category).length;
  }

  ServicePlan[] filterByCategory(ServicePlan[] items, ServicePlanCategory category) {
    return items.filter!(e => e.category == category).array;
  }

  ServicePlan[] findByCategory(ServicePlanCategory category) {
    return findAll().filterByCategory(category).array;
  }

  void removeByCategory(ServicePlanCategory category, bool deleteTenantIfEmpty = false) {
    findByCategory(category).removeAll(deleteTenantIfEmpty);
  }
  // #endregion ByCategory

  // #region ByRegion
  size_t countByRegion(string region) {
    return findByRegion(region).length;
  }

  ServicePlan[] filterByRegion(ServicePlan[] items, string region) {
    return items.filter!(e => e.availableRegions.canFind(region)).array;
  }

  ServicePlan[] findByRegion(string region) {
    return findAll().filterByRegion(region).array;
  }

  void removeByRegion(string region, bool deleteTenantIfEmpty = false) {
    findByRegion(region).removeAll(deleteTenantIfEmpty);
  }
  // #endregion ByRegion

}
