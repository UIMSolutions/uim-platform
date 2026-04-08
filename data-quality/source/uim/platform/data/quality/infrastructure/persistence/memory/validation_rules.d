/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.infrastructure.persistence.memory.validation_rules;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.validation_rule;
import uim.platform.data.quality.domain.ports.repositories.validation_rules;

// import std.algorithm : filter;
// import std.array : array;

class MemoryValidationRuleRepository : ValidationRuleRepository {
  private ValidationRule[RuleId] store;

  ValidationRule[] findAll() {
    return store.byValue().array;
  }

  ValidationRule[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(r => r.tenantId == tenantId).array;
  }

  ValidationRule* findById(RuleId id) {
    if (auto p = id in store)
      return p;
    return null;
  }

  ValidationRule[] findByDataset(TenantId tenantId, string datasetPattern) {
    return store.byValue().filter!(r => r.tenantId == tenantId
        && r.datasetPattern == datasetPattern).array;
  }

  ValidationRule[] findByField(TenantId tenantId, string fieldName) {
    return store.byValue().filter!(r => r.tenantId == tenantId && r.fieldName == fieldName).array;
  }

  ValidationRule[] findActive(TenantId tenantId) {
    return store.byValue().filter!(r => r.tenantId == tenantId && r.status == RuleStatus.active)
      .array;
  }

  void save(ValidationRule rule) {
    store[rule.id] = rule;
  }

  void update(ValidationRule rule) {
    store[rule.id] = rule;
  }

  void remove(RuleId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
