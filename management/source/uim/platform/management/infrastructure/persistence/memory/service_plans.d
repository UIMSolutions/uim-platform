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
  mixin TenantRepositoryTemplate!(MemoryServicePlanRepository, ServicePlan, ServicePlanId);

  size_t countByService(string serviceName) {
    return findByService(serviceName).length;
  }
  ServicePlan[] findByService(string serviceName) {
    return findAll()r!(e => e.serviceName == serviceName).array;
  }

  ServicePlan[] findByCategory(ServicePlanCategory category) {
    return findAll()r!(e => e.category == category).array;
  }

  ServicePlan[] findByRegion(string region) {
    return findAll()r!(e => e.availableRegions.canFind(region)).array;
  }

  ServicePlan[] findAll() {
    return findAll();
  }

  void save(ServicePlan plan) {
    store[plan.id] = plan;
  }

  void update(ServicePlan plan) {
    store[plan.id] = plan;
  }

  void remove(ServicePlanId id) {
    store.remove(id);
  }
}
