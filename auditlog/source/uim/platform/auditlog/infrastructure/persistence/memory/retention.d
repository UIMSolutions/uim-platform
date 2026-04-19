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
class MemoryRetentionPolicyRepository : TenantRepository!(RetentionPolicy, RetentionPolicyId), RetentionPolicyRepository {
  bool existsDefault(TenantId tenantId) {
    return findByTenant(tenantId).any!(p => p.isDefault && p.status == RetentionStatus.active);
  }

  RetentionPolicy findDefault(TenantId tenantId) {
    foreach (p; findByTenant(tenantId))
      if (p.isDefault && p.status == RetentionStatus.active)
        return p;
    return RetentionPolicy.init;
  }
}
