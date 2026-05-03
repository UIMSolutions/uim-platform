/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.memory.environments;

// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.domain.entities.kyma_environment;
// import uim.platform.kyma.domain.ports.repositories.environments;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class MemoryEnvironmentRepository : TenantRepository!(KymaEnvironment, KymaEnvironmentId), EnvironmentRepository {

  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findBySubaccount(tenantId, subaccountId).length;
  }
  KymaEnvironment[] filterBySubaccount(KymaEnvironment[] envs, SubaccountId subaccountId) {
    return envs.filter!(e => e.subaccountId == subaccountId).array;
  }
  KymaEnvironment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return filterBySubaccount(findByTenant(tenantId), subaccountId);
  }
  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    findBySubaccount(tenantId, subaccountId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, EnvironmentStatus status) {
    return findByStatus(status).length;
  }
  KymaEnvironment[] filterByStatus(KymaEnvironment[] envs, EnvironmentStatus status) {
    return envs.filter!(e => e.status == status).array;
  }
  KymaEnvironment[] findByStatus(EnvironmentStatus status) {
    return filterByStatus(findAll(), status);
  }
  void removeByStatus(EnvironmentStatus status) {
    findByStatus(status).each!(e => remove(e));
  }

}
