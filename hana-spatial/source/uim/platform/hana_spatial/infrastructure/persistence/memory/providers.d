/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.infrastructure.persistence.memory.providers;

import uim.platform.hana_spatial;

// mixin(ShowModule!());

@safe:
class MemoryProviderRepository
  : TenantRepository!(Provider, ProviderId),
    ProviderRepository {

  Provider[] findByType(TenantId tenantId, ProviderType type) {
    Provider[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.type == type) results ~= item;
    }
    return results;
  }

  Provider[] findActive(TenantId tenantId) {
    Provider[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.status == ProviderStatus.active) results ~= item;
    }
    return results;
  }

  Provider[] findByStatus(TenantId tenantId, ProviderStatus status) {
    Provider[] results;
    foreach (item; findByTenant(tenantId)) {
      if (item.status == status) results ~= item;
    }
    return results;
  }
}
