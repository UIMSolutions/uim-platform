/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.environment_instances;
// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.environment_instance;
// import uim.platform.management.domain.ports.repositories.environment_instances;
// 
//  

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemoryEnvironmentInstanceRepository : TenantRepository!(EnvironmentInstance, EnvironmentInstanceId), EnvironmentInstanceRepository {
  // TODO: mixin IdRepositoryTemplate!(MemoryEnvironmentInstanceRepository, EnvironmentInstance, EnvironmentInstanceId);

  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findBySubaccount(tenantId, subaccountId).length;
  }

  EnvironmentInstance[] filterBySubaccount(EnvironmentInstance[] items, SubaccountId subaccountId) {
    return items.filter!(e => e.subaccountId == subaccountId).array;
  }

  EnvironmentInstance[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return filterBySubaccount(findByTenant(tenantId), subaccountId);
  }

  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    findBySubaccount(tenantId, subaccountId).each!(e => remove(e));
  }

  size_t countByType(TenantId tenantId, SubaccountId subaccountId, EnvironmentType envType) {
    return findByType(tenantId, subaccountId, envType).length;
  }

  EnvironmentInstance[] filterByType(EnvironmentInstance[] items, SubaccountId subaccountId, EnvironmentType envType) {
    return items.filter!(e => e.subaccountId == subaccountId && e.environmentType == envType).array;
  }
  
  EnvironmentInstance[] findByType(TenantId tenantId, SubaccountId subaccountId, EnvironmentType envType) {
    return filterByType(findByTenant(tenantId), subaccountId, envType);
  }

  void removeByType(TenantId tenantId, SubaccountId subaccountId, EnvironmentType envType) {
    findByType(tenantId, subaccountId, envType).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, SubaccountId subaccountId, EnvironmentStatus status) {
    return findByStatus(tenantId, subaccountId, status).length;
  }

  EnvironmentInstance[] filterByStatus(EnvironmentInstance[] items, SubaccountId subaccountId, EnvironmentStatus status) {
    return items.filter!(e => e.subaccountId == subaccountId && e.status == status).array;
  }

  EnvironmentInstance[] findByStatus(TenantId tenantId, SubaccountId subaccountId, EnvironmentStatus status) {
    return filterByStatus(findByTenant(tenantId), subaccountId, status);
  }

  void removeByStatus(TenantId tenantId, SubaccountId subaccountId, EnvironmentStatus status) {
    findByStatus(tenantId, subaccountId, status).each!(e => remove(e));
  }

}
///
unittest {
  auto repo = new MemoryEnvironmentInstanceRepository();

  auto tenantId = TenantId("tenant1");
  auto subaccountId = SubaccountId("sa1");
  auto envType = EnvironmentType.production;
  auto status = EnvironmentStatus.active; 
  auto envId = EnvironmentInstanceId("env1"); 
  auto env = EnvironmentInstance(tenantId);
  env.id = envId;
  env.subaccountId = subaccountId;
  env.environmentType = envType;
  env.status = status;

  repo.save(env); 
  // Test findBySubaccount  
  auto bySubaccount = repo.findBySubaccount(tenantId, subaccountId);
  assert(bySubaccount.length == 1);
  assert(bySubaccount[0].id == envId);  
  // Test findByType
  auto byType = repo.findByType(tenantId, subaccountId, envType);
  assert(byType.length == 1);
  assert(byType[0].id == envId);
  // Test findByStatus    
  auto byStatus = repo.findByStatus(tenantId, subaccountId, status);
  assert(byStatus.length == 1);
  assert(byStatus[0].id == envId);
} 