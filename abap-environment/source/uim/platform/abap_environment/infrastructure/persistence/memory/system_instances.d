/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory.system_instances;

// import uim.platform.abap_environment.domain.types;
// import uim.platform.abap_environment.domain.entities.system_instance;
// import uim.platform.abap_environment.domain.ports.repositories.system_instances;
// 
// // import std.algorithm : filter;
// // import std.array : array;
import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:
class MemorySystemInstanceRepository : SystemInstanceRepository {
  private SystemInstance[SystemInstanceId] store;

  SystemInstance findById(SystemInstanceId id) {
    if (id in store)
      return store[id];
    return SystemInstance.init;
  }

  SystemInstance[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  SystemInstance findByName(TenantId tenantId, string name) {
    foreach (e; store.byValue())
      if (e.tenantId == tenantId && e.name == name)
        return e;
    return SystemInstance.init;
  }

  SystemInstance[] findByStatus(TenantId tenantId, SystemStatus status) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.status == status).array;
  }

  void save(SystemInstance instance) {
    store[instance.id] = instance;
  }

  void update(SystemInstance instance) {
    store[instance.id] = instance;
  }

  void remove(SystemInstanceId id) {
    store.remove(id);
  }
}
