/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.repositories.service_bindings;

// import uim.platform.abap_environment.domain.entities.service_binding;
// import uim.platform.abap_environment.domain.ports.repositories.service_bindings;

import uim.platform.abap_environment;

// mixin(ShowModule!());
@safe:
class MemoryServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), ServiceBindingRepository {

  // #region BySystem
  size_t countBySystem(TenantId tenantId, SystemInstanceId instanceId) {
    return findBySystem(tenantId, instanceId).length;
  }
  ServiceBinding[] filterBySystem(ServiceBinding[] bindings, SystemInstanceId instanceId) {
    return bindings.filter!(e => e.instanceId == instanceId).array;
  }
  ServiceBinding[] findBySystem(TenantId tenantId, SystemInstanceId instanceId) {
    return filterBySystem(findByTenant(tenantId), instanceId);
  }
  void removeBySystem(TenantId tenantId, SystemInstanceId instanceId) {
    findBySystem(tenantId, instanceId).each!(e => remove(e));
  }
  // #endregion BySystem

  // #region ByType
  size_t countByType(TenantId tenantId, SystemInstanceId instanceId, BindingType type) {
    return findByType(tenantId, instanceId, type).length;
  }
  ServiceBinding[] filterByType(ServiceBinding[] bindings, BindingType type) {
    return bindings.filter!(e => e.bindingType == type).array;
  }
  ServiceBinding[] findByType(TenantId tenantId, SystemInstanceId instanceId, BindingType type) {
    return filterByType(findBySystem(tenantId, instanceId), type);
  }
  void removeByType(TenantId tenantId, SystemInstanceId instanceId, BindingType type) {
    findByType(tenantId, instanceId, type).each!(e => remove(e));
  }
  // #endregion ByType
  
}
