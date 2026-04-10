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

class MemoryServicePlanRepository : ServicePlanRepository {
  private ServicePlan[ServicePlanId] store;

  bool existsById(ServicePlanId id) {
    return (id in store) ? true : false;
  }

  ServicePlan findById(ServicePlanId id) {
    return existsById(id) ? store[id] : ServicePlan.init;
  }

  ServicePlan[] findByService(string serviceName) {
    return store.byValue().filter!(e => e.serviceName == serviceName).array;
  }

  ServicePlan[] findByCategory(ServicePlanCategory category) {
    return store.byValue().filter!(e => e.category == category).array;
  }

  ServicePlan[] findByRegion(string region) {
    return store.byValue().filter!(e => e.availableRegions.canFind(region)).array;
  }

  ServicePlan[] findAll() {
    return store.byValue().array;
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
