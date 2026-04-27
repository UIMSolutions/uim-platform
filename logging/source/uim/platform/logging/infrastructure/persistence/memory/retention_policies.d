/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.retention_policies;

//import uim.platform.logging.domain.entities.retention_policy;
//import uim.platform.logging.domain.ports.repositories.retention_policys;
//import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:

class MemoryRetentionPolicyRepository : TenantRepository!(RetentionPolicy, RetentionPolicyId), RetentionPolicyRepository {

  RetentionPolicy[] findByTenant(TenantId tenantId) {
    return store.byValue.filter!(p => p.tenantId == tenantId).array;
  }

  bool existsDefault(TenantId tenantId) {
    return findByTenant(tenantId).any!(p => p.isDefault);
  }
  RetentionPolicy findDefault(TenantId tenantId) {
    foreach (p; findByTenant(tenantId))
      if (p.isDefault)
        return p;
    return RetentionPolicy.init;
  }

  size_t countByDataType(TenantId tenantId, DataType dt) {
    return findByDataType(tenantId, dt).length;
  }
  RetentionPolicy[] filterByDataType(RetentionPolicy[] policies, TenantId tenantId, DataType dt) {
    return policies.filter!(p => p.tenantId == tenantId && (p.dataType == dt || p.dataType == DataType.all)).array;
  }
  RetentionPolicy[] findByDataType(TenantId tenantId, DataType dt) {
    return store.byValue.filter!(p => p.tenantId == tenantId && (p.dataType == dt || p.dataType == DataType.all)).array;
  }
  void removeByDataType(TenantId tenantId, DataType dt) {
    findByDataType(tenantId, dt).each!(p => remove(p.id));
  }

}
