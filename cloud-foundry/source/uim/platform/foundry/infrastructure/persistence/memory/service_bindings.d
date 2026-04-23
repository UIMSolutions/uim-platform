/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.service_binding;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.service_binding;
// import uim.platform.foundry.domain.ports.repositories.service_binding;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class MemoryServiceBindingRepository : ServiceBindingRepository {

  size_t countByApp(TenantId tenantId, AppId appId) {
    return findByApp(tenantId, appId).length;
  }

  ServiceBinding[] findByApp(TenantId tenantId, AppId appId) {
    return findAll().filter!(e => e.tenantId == tenantId && e.appId == appId).array;
  }

  void removeByApp(TenantId tenantId, AppId appId) {
    findByApp(tenantId, appId).each!(e => remove(e));
  }

  size_t countByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return findByServiceInstance(tenantId, instanceId).length;
  }

  ServiceBinding[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return findByTenant(tenantId).filter!(e => e.serviceInstanceId == instanceId).array;
  }

  void removeByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    findByServiceInstance(tenantId, instanceId).each!(e => remove(e));
  }

}
