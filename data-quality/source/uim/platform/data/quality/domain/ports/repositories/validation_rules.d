/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.ports.repositories.validation_rules;

// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.validation_rule;

import uim.platform.data.quality;

mixin(ShowModule!());

@safe:

/// Port for persisting validation rules.
interface ValidationRuleRepository : ITenantRepository!(ValidationRule, ValidationRule) {
  
  size_t countByDataset(TenantId tenantId, string datasetPattern);
  ValidationRule[] findByDataset(TenantId tenantId, string datasetPattern);
  void removeByDataset(TenantId tenantId, string datasetPattern);

  size_t countByField(TenantId tenantId, string fieldName);
  ValidationRule[] findByField(TenantId tenantId, string fieldName);
  void removeByField(TenantId tenantId, string fieldName);

  size_t countActive(TenantId tenantId);
  ValidationRule[] findActive(TenantId tenantId);
  void removeActive(TenantId tenantId);

}
