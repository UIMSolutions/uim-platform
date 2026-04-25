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

class MemoryValidationRuleRepository : TenantRepository!(ValidationRule, RuleId), ValidationRuleRepository {

  size_t countByDataset(TenantId tenantId, string datasetPattern) {
    return findByDataset(tenantId, datasetPattern).length;
  }

  ValidationRule[] findByDataset(TenantId tenantId, string datasetPattern) {
    return findByTenant(tenantId).filter!(r => r.datasetPattern == datasetPattern).array;
  }

  void removeByDataset(TenantId tenantId, string datasetPattern) {
    findByDataset(tenantId, datasetPattern).each!(entity => remove(entity.id));
  } 

  size_t countByField(TenantId tenantId, string fieldName) {
    return findByField(tenantId, fieldName).length;
  } 

  ValidationRule[] findByField(TenantId tenantId, string fieldName) {
    return findByTenant(tenantId).filter!(r => r.fieldName == fieldName).array;
  }

  void removeByField(TenantId tenantId, string fieldName) {
    findByField(tenantId, fieldName).each!(entity => remove(entity.id));
  }

  size_t countActive(TenantId tenantId) {
    return findActive(tenantId).length;
  }

  ValidationRule[] findActive(TenantId tenantId) {
    return findByTenant(tenantId).filter!(r => r.status == RuleStatus.active).array;
  }

  void removeActive(TenantId tenantId) {
    findActive(tenantId).each!(entity => remove(entity.id));
  }
}
