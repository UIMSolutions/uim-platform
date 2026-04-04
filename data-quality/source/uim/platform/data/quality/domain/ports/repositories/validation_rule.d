/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.ports.repositories.validation_rules;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.validation_rule;

/// Port for persisting validation rules.
interface ValidationRuleRepository
{
  ValidationRule[] findAll();
  ValidationRule[] findByTenant(TenantId tenantId);
  ValidationRule* findById(RuleId id);
  ValidationRule[] findByDataset(TenantId tenantId, string datasetPattern);
  ValidationRule[] findByField(TenantId tenantId, string fieldName);
  ValidationRule[] findActive(TenantId tenantId);
  void save(ValidationRule rule);
  void update(ValidationRule rule);
  void remove(RuleId id, TenantId tenantId);
}
