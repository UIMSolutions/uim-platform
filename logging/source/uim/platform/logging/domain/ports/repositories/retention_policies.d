/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.repositories.retention_policies;

// import uim.platform.logging.domain.entities.retention_policy;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
interface RetentionPolicyRepository : ITenantRepository!(RetentionPolicy, RetentionPolicyId) {

  bool existsDefault(TenantId tenantId);
  RetentionPolicy findDefault(TenantId tenantId);
  void removeDefault(TenantId tenantId);

  size_t countByDataType(TenantId tenantId, DataType dt);
  RetentionPolicy[] findByDataType(TenantId tenantId, DataType dt);
  void removeByDataType(TenantId tenantId, DataType dt);

}
