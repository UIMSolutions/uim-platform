/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.infrastructure.persistence.repositories.composition_runs;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:
class MemoryCompositionRunRepository
    : TenantRepository!(CompositionRun, CompositionRunId),
      CompositionRunRepository {

  CompositionRun[] findByStatus(TenantId tenantId, CompositionRunStatus status) {
    CompositionRun[] result;
    foreach (item; findByTenant(tenantId)) {
      if (item.status == status) result ~= item;
    }
    return result;
  }

  CompositionRun[] findRecent(TenantId tenantId, int limit) {
    import std.algorithm : sort;
    auto items = findByTenant(tenantId);
    items.sort!((a, b) => a.createdAt > b.createdAt);
    if (items.length > limit) return items[0 .. limit];
    return items;
  }
}
