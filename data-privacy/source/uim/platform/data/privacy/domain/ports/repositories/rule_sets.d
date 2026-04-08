/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.rule_sets;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.rule_set;

/// Port for persisting and querying rule sets.
interface RuleSetRepository {
  bool existsByTenant(TenantId tenantId);
  RuleSet[] findByTenant(TenantId tenantId);
 
  bool existsById(RuleSetId id, TenantId tenantId);
  RuleSet findById(RuleSetId id, TenantId tenantId);

  RuleSet[] findByBusinessContext(TenantId tenantId, BusinessContextId contextId);
  RuleSet[] findByStatus(TenantId tenantId, RuleSetStatus status);

  void save(RuleSet ruleSet);
  void update(RuleSet ruleSet);
  void remove(RuleSetId id, TenantId tenantId);
}
