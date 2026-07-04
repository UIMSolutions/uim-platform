/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.memory.modules;

// import uim.platform.kyma.domain.entities.kyma_module;
// import uim.platform.kyma.domain.ports.repositories.modules;
 
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class MemoryModuleRepository : TenantRepository!(KymaModule, KymaModuleId), ModuleRepository {
  
  bool existsByName(TenantId tenantId, KymaEnvironmentId environmentId, string name) {
    return findByTenant(tenantId).any!(e => e.environmentId == environmentId && e.name == name);
  }

  KymaModule findByName(TenantId tenantId, KymaEnvironmentId environmentId, string name) {
    foreach (enviroment; findByEnvironment(tenantId, environmentId))
      if (enviroment.name == name)
        return enviroment;
    return KymaModule.init;
  }

  void removeByName(TenantId tenantId, KymaEnvironmentId environmentId, string name) {
    findByEnvironment(tenantId, environmentId).each!(enviroment => {
      if (enviroment.name == name)
        remove(enviroment);
    });
  }

  size_t countByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId) {
    return findByEnvironment(tenantId, environmentId).length;
  }

  KymaModule[] filterByEnvironment(KymaModule[] modules, KymaEnvironmentId environmentId) {
    return modules.filter!(enviroment => enviroment.environmentId == environmentId).array;
  }

  KymaModule[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId) {
    return filterByEnvironment(findByTenant(tenantId), environmentId);
  }

  void removeByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId) {
    findByEnvironment(tenantId, environmentId).each!(enviroment => remove(enviroment));
  }

  size_t countByStatus(TenantId tenantId, ModuleStatus status) {
    return findByStatus(tenantId, status).length;
  }

  KymaModule[] filterByStatus(KymaModule[] modules, ModuleStatus status) {
    return modules.filter!(enviroment => enviroment.status == status).array;
  }

  KymaModule[] findByStatus(TenantId tenantId, ModuleStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, ModuleStatus status) {
    findByStatus(tenantId, status).each!(enviroment => remove(enviroment));
  }

  size_t countByType(TenantId tenantId, ModuleType moduleType) {
    return findByType(tenantId, moduleType).length;
  }

  KymaModule[] filterByType(KymaModule[] modules, ModuleType moduleType) {
    return modules.filter!(enviroment => enviroment.moduleType == moduleType).array;
  }

  KymaModule[] findByType(TenantId tenantId, ModuleType moduleType) {
    return filterByType(findByTenant(tenantId), moduleType);
  }

  void removeByType(TenantId tenantId, ModuleType moduleType) {
    findByType(tenantId, moduleType).each!(enviroment => remove(enviroment));
  }

}
