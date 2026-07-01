/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory.service_bindings;

// import uim.platform.abap_environment.domain.entities.service_binding;
// import uim.platform.abap_environment.domain.ports.repositories.service_bindings;

import uim.platform.abap_environment;

// mixin(ShowModule!());
@safe:
class MemoryServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), ServiceBindingRepository {

  // #region BySystem
  size_t countBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return findBySystem(tenantId, systemId).length;
  }
  ServiceBinding[] filterBySystem(ServiceBinding[] bindings, SystemInstanceId systemId) {
    return bindings.filter!(e => e.systemInstanceId == systemId).array;
  }
  ServiceBinding[] findBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return filterBySystem(findByTenant(tenantId), systemId);
  }
  void removeBySystem(TenantId tenantId, SystemInstanceId systemId) {
    findBySystem(tenantId, systemId).each!(e => remove(e));
  }
  // #endregion BySystem

  // #region ByType
  size_t countByType(TenantId tenantId, SystemInstanceId systemId, BindingType bindingType) {
    return findByType(tenantId, systemId, bindingType).length;
  }
  ServiceBinding[] filterByType(ServiceBinding[] bindings, BindingType bindingType) {
    return bindings.filter!(e => e.bindingType == bindingType).array;
  }
  ServiceBinding[] findByType(TenantId tenantId, SystemInstanceId systemId, BindingType bindingType) {
    return filterByType(findBySystem(tenantId, systemId), bindingType);
  }
  void removeByType(TenantId tenantId, SystemInstanceId systemId, BindingType bindingType) {
    findByType(tenantId, systemId, bindingType).each!(e => remove(e));
  }
  // #endregion ByType
  
}
