/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.infrastructure.persistence.memory.in_memory_content_provider;

import uim.platform.content_agent.domain.types;
import uim.platform.content_agent.domain.entities.content_provider;
import uim.platform.content_agent.domain.ports.repositories.content_providers;

// import std.algorithm : filter;
// import std.array : array;

class MemoryContentProviderRepository : ContentProviderRepository {
  private ContentProvider[ContentProviderId] store;

  ContentProvider findById(ContentProviderId id) {
    if (auto p = id in store)
      return *p;
    return ContentProvider.init;
  }

  ContentProvider[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  ContentProvider findByName(TenantId tenantId, string name) {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.name == name)
        return e;
    return ContentProvider.init;
  }

  ContentProvider[] findByStatus(TenantId tenantId, ProviderStatus status) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.status == status).array;
  }

  void save(ContentProvider provider) {
    store[provider.id] = provider;
  }

  void update(ContentProvider provider) {
    store[provider.id] = provider;
  }

  void remove(ContentProviderId id) {
    store.remove(id);
  }
}
