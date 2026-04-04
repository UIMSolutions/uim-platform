/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.infrastructure.persistence.memory.providers;

// import uim.platform.portal.domain.entities.content_provider;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.provider_repository;

import uim.platform.portal;

mixin(ShowModule!());

@safe:
class MemoryProviderRepository : ProviderRepository {
  private ContentProvider[ProviderId] store;

  ContentProvider findById(ProviderId id) {
    if (auto p = id in store)
      return *p;
    return ContentProvider.init;
  }

  ContentProvider[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100) {
    ContentProvider[] result;
    uint idx;
    foreach (cp; store.byValue()) {
      if (cp.tenantId == tenantId) {
        if (idx >= offset && result.length < limit)
          result ~= cp;
        idx++;
      }
    }
    return result;
  }

  void save(ContentProvider provider) {
    store[provider.id] = provider;
  }

  void update(ContentProvider provider) {
    store[provider.id] = provider;
  }

  void remove(ProviderId id) {
    store.remove(id);
  }
}
