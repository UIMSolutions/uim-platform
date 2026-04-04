/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.infrastructure.persistence.memory.retention;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.retention_policy;
// import uim.platform.auditlog.domain.ports.repositories.retention_policys;

// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class MemoryRetentionPolicyRepository : RetentionPolicyRepository
{
  private RetentionPolicy[RetentionPolicyId] store;

  bool existsById(RetentionPolicyId id, TenantId tenantId)
  {
    return id in store && store[id].tenantId == tenantId;
  }

  RetentionPolicy findById(RetentionPolicyId id, TenantId tenantId)
  {
    if (existsById(id, tenantId))
      return store[id];
    return RetentionPolicy.init;
  }

  bool existsDefault(TenantId tenantId)
  {
    return findByTenant(tenantId).any!(p => p.isDefault && p.status == RetentionStatus.active);
  }

  RetentionPolicy findDefault(TenantId tenantId)
  {
    foreach (ref p; findByTenant(tenantId))
      if (p.isDefault && p.status == RetentionStatus.active)
        return p;
    return RetentionPolicy.init;
  }

  RetentionPolicy[] findByTenant(TenantId tenantId)
  {
    return store.byValue.filter!(p => p.tenantId == tenantId).array;
  }

  void save(RetentionPolicy policy)
  {
    store[policy.id] = policy;
  }

  void update(RetentionPolicy policy)
  {
    store[policy.id] = policy;
  }

  void remove(RetentionPolicyId id, TenantId tenantId)
  {
    if (existsById(id, tenantId))
      store.remove(id);
  }
}
