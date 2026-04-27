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
class MemoryEnvironmentRepository :TenantRepository!(KymaEnvironment, KymaEnvironmentId), EnvironmentRepository {
  private KymaEnvironment[KymaEnvironmentId] store;

  bool existsById(KymaEnvironmentId id) {
    return (id in store) ? true : false;
  }

  KymaEnvironment findById(KymaEnvironmentId id) {
    if (existsById(id))
      return store[id];
    return KymaEnvironment.init;
  }

  KymaEnvironment[] findByTenant(TenantId tenantId) {
    return findAll()r!(e => e.tenantId == tenantId).array;
  }

  KymaEnvironment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findAll()r!(e => e.tenantId == tenantId
        && e.subaccountId == subaccountId).array;
  }

  KymaEnvironment[] findByStatus(EnvironmentStatus status) {
    return findAll()r!(e => e.status == status).array;
  }

  void save(KymaEnvironment env) {
    store[env.id] = env;
  }

  void update(KymaEnvironment env) {
    store[env.id] = env;
  }

  void remove(KymaEnvironmentId id) {
    store.remove(id);
  }
}
