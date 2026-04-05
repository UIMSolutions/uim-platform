/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.repositories.retention_policys;

import uim.platform.logging.domain.entities.retention_policy;
import uim.platform.logging.domain.types;

interface RetentionPolicyRepository {
  RetentionPolicy findById(RetentionPolicyId id);
  RetentionPolicy[] findByTenant(TenantId tenantId);
  RetentionPolicy findDefault(TenantId tenantId);
  RetentionPolicy[] findByDataType(TenantId tenantId, DataType dt);
  void save(RetentionPolicy p);
  void update(RetentionPolicy p);
  void remove(RetentionPolicyId id);
}
