/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.ports.repositories.retention_policies;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.retention_policy;

import uim.platform.auditlog;

mixin(ShowModule!());

/// Port for persisting retention policies.
@safe:
interface RetentionPolicyRepository {
  bool existsById(RetentionPolicyId id, TenantId tenantId);
  RetentionPolicy findById(RetentionPolicyId id, TenantId tenantId);

  bool existsDefault(TenantId tenantId);
  RetentionPolicy findDefault(TenantId tenantId);

  RetentionPolicy[] findByTenant(TenantId tenantId);

  void save(RetentionPolicy policy);
  void update(RetentionPolicy policy);
  void remove(RetentionPolicyId id, TenantId tenantId);
}
