/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.retention_policy;

import uim.platform.logging.domain.entities.retention_policy;
import uim.platform.logging.domain.ports.repositories.retention_policys;
import uim.platform.logging.domain.types;

class MemoryRetentionPolicyRepository : RetentionPolicyRepository {
  private RetentionPolicy[RetentionPolicyId] store;

  RetentionPolicy findById(RetentionPolicyId id) {
    if (auto p = id in store)
      return *p;
    return RetentionPolicy.init;
  }

  RetentionPolicy[] findByTenant(TenantId tenantId) {
    RetentionPolicy[] result;
    foreach (p; store)
      if (p.tenantId == tenantId)
        result ~= p;
    return result;
  }

  RetentionPolicy findDefault(TenantId tenantId) {
    foreach (p; store)
      if (p.tenantId == tenantId && p.isDefault)
        return p;
    return RetentionPolicy.init;
  }

  RetentionPolicy[] findByDataType(TenantId tenantId, DataType dt) {
    RetentionPolicy[] result;
    foreach (p; store)
      if (p.tenantId == tenantId && (p.dataType == dt || p.dataType == DataType.all))
        result ~= p;
    return result;
  }

  void save(RetentionPolicy p) {
    store[p.id] = p;
  }

  void update(RetentionPolicy p) {
    store[p.id] = p;
  }

  void remove(RetentionPolicyId id) {
    store.remove(id);
  }
}
