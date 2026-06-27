/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory.system_instances;

// import uim.platform.abap_environment.domain.entities.system_instance;
// import uim.platform.abap_environment.domain.ports.repositories.system_instances;
import uim.platform.abap_environment;

// // mixin(ShowModule!());
@safe:
class MemorySystemInstanceRepository : TenantRepository!(SystemInstance, SystemInstanceId), SystemInstanceRepository {

  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(e => e.tenantId == tenantId && e.name == name);
  }
  SystemInstance findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.tenantId == tenantId && e.name == name)
        return e;
    return SystemInstance.init;
  }

  void removeByName(TenantId tenantId, string name) {
    auto instance = findByName(tenantId, name);
    if (!instance.isNull)
      remove(instance);
  }
  
  size_t countByStatus(TenantId tenantId, SystemStatus status) {
    return findByStatus(tenantId, status).length;
  }

  SystemInstance[] filterByStatus(SystemInstance[] instances, SystemStatus status) {
    return instances.filter!(e => e.status == status).array;
  }

  SystemInstance[] findByStatus(TenantId tenantId, SystemStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, SystemStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity));
  }

}
