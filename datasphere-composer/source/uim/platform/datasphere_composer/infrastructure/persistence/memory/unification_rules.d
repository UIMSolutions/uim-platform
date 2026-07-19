/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.infrastructure.persistence.memory.unification_rules;

import uim.platform.datasphere_composer;
mixin(ShowModule!());

@safe:
class MemoryUnificationRuleRepository
    : TenantRepository!(UnificationRule, UnificationRuleId),
      UnificationRuleRepository {

  UnificationRule[] findByPriority(TenantId tenantId) {
    import std.algorithm : sort;
    auto items = findByTenant(tenantId);
    items.sort!((a, b) => a.priority < b.priority);
    return items;
  }

  UnificationRule[] findActive(TenantId tenantId) {
    UnificationRule[] result;
    foreach (item; findByTenant(tenantId)) {
      if (item.active) result ~= item;
    }
    return result;
  }
}
