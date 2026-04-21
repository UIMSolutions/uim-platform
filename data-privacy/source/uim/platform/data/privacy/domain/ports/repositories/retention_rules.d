/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.retention_rules;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.retention_rule;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting data retention rules.
interface RetentionRuleRepository : ITenantRepository!(RetentionRule, RetentionRuleId) {

  bool existsDefault(TenantId tenantId);
  RetentionRule findDefault(TenantId tenantId);
  void removeDefault(TenantId tenantId);

  size_t countByPurpose(TenantId tenantId, ProcessingPurpose purpose);
  RetentionRule[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose);
  void removeByPurpose(TenantId tenantId, ProcessingPurpose purpose);

}
