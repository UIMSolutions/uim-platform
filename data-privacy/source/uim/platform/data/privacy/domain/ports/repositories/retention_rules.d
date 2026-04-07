/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.retention_rules;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.retention_rule;

/// Port for persisting data retention rules.
interface RetentionRuleRepository {
  bool existsTenant(TenantId tenantId);
  RetentionRule[] findByTenant(TenantId tenantId);
 
  bool existsId(RetentionRuleId id, TenantId tenantId);
  RetentionRule findById(RetentionRuleId id, TenantId tenantId);

  RetentionRule findDefault(TenantId tenantId);
  RetentionRule[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose);

  void save(RetentionRule rule);
  void update(RetentionRule rule);
  void remove(RetentionRuleId id, TenantId tenantId);
}
