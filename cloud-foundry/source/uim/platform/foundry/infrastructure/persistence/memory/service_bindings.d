/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.service_bindings;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.service_binding;
// import uim.platform.foundry.domain.ports.repositories.service_binding;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class MemoryServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), IServiceBindingRepository {

  size_t countByApp(TenantId tenantId, AppId appId) {
    return findByApp(tenantId, appId).length;
  }

  ServiceBinding[] filterByApp(ServiceBinding[] bindings, AppId appId) {
    return bindings.filter!(e => e.appId == appId).array;
  }

  ServiceBinding[] findByApp(TenantId tenantId, AppId appId) {
    return filterByApp(findByTenant(tenantId), appId);
  }

  void removeByApp(TenantId tenantId, AppId appId) {
    findByApp(tenantId, appId).each!(e => remove(e));
  }

  size_t countByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return findByServiceInstance(tenantId, instanceId).length;
  }

  ServiceBinding[] filterByServiceInstance(ServiceBinding[] bindings, ServiceInstanceId instanceId) {
    return bindings.filter!(e => e.serviceInstanceId == instanceId).array;
  }

  ServiceBinding[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return filterByServiceInstance(findByTenant(tenantId), instanceId);
  }

  void removeByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    findByServiceInstance(tenantId, instanceId).each!(e => remove(e));
  }

}
