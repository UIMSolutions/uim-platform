/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.retention_policy;

//import uim.platform.logging.domain.entities.retention_policy;
//import uim.platform.logging.domain.ports.repositories.retention_policys;
//import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:

class MemoryRetentionPolicyRepository : RetentionPolicyRepository {
  private RetentionPolicy[RetentionPolicyId] store;

  bool existsById(RetentionPolicyId id) {
    return (  id in store) ? true : false;
  }

  RetentionPolicy findById(RetentionPolicyId id) {
    return (existsById(id)) ? store[id] : RetentionPolicy.init;
  }

  RetentionPolicy[] findByTenant(TenantId tenantId) {
    return store.byValue.filter!(p => p.tenantId == tenantId).array;
  }

  RetentionPolicy findDefault(TenantId tenantId) {
    foreach (p; findByTenant(tenantId))
      if (p.isDefault)
        return p;
    return RetentionPolicy.init;
  }

  RetentionPolicy[] findByDataType(TenantId tenantId, DataType dt) {
    return store.byValue.filter!(p => p.tenantId == tenantId && (p.dataType == dt || p.dataType == DataType.all)).array;
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
