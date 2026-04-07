/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.retention_rules;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.retention_rule;
// import uim.platform.data.privacy.domain.ports.repositories.retention_rules;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryRetentionRuleRepository : RetentionRuleRepository {
  private RetentionRule[] store;

  RetentionRule[] findByTenant(TenantId tenantId) {
    RetentionRule[] result;
    foreach (ref r; store)
      if (r.tenantId == tenantId)
        result ~= r;
    return result;
  }

  RetentionRule* findById(RetentionRuleId id, TenantId tenantId) {
    foreach (ref r; store)
      if (r.id == id && r.tenantId == tenantId)
        return &r;
    return null;
  }

  RetentionRule* findDefault(TenantId tenantId) {
    foreach (ref r; store)
      if (r.tenantId == tenantId && r.isDefault && r.status == RetentionRuleStatus.active)
        return &r;
    return null;
  }

  RetentionRule[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose) {
    RetentionRule[] result;
    foreach (ref r; store)
      if (r.tenantId == tenantId && r.purpose == purpose)
        result ~= r;
    return result;
  }

  void save(RetentionRule rule) {
    store ~= rule;
  }

  void update(RetentionRule rule) {
    foreach (ref r; store)
      if (r.id == rule.id && r.tenantId == rule.tenantId) {
        r = rule;
        return;
      }
  }

  void remove(RetentionRuleId id, TenantId tenantId) {
    RetentionRule[] kept;
    foreach (ref r; store)
      if (!(r.id == id && r.tenantId == tenantId))
        kept ~= r;
    store = kept;
  }
}
