/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory.service_bindings;

// import uim.platform.abap_environment.domain.types;
// import uim.platform.abap_environment.domain.entities.service_binding;
// import uim.platform.abap_environment.domain.ports.repositories.service_bindings;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:
class MemoryServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), ServiceBindingRepository {

  // #region BySystem
  size_t countBySystem(SystemInstanceId systemId) {
    return findBySystem(systemId).length;
  }
  ServiceBinding[] findBySystem(SystemInstanceId systemId) {
    return findAll().filter!(e => e.systemInstanceId == systemId).array;
  }
  void removeBySystem(SystemInstanceId systemId) {
    findBySystem(systemId).each!(e => remove(e));
  }
  // #endregion BySystem

  // #region ByType
  size_t countByType(SystemInstanceId systemId, BindingType bindingType) {
    return findByType(systemId, bindingType).length;
  }
  ServiceBinding[] findByType(SystemInstanceId systemId, BindingType bindingType) {
    return findAll().filter!(e => e.systemInstanceId == systemId
        && e.bindingType == bindingType).array;
  }
  void removeByType(SystemInstanceId systemId, BindingType bindingType) {
    findByType(systemId, bindingType).each!(e => remove(e));
  }
  // #endregion ByType
  
}
