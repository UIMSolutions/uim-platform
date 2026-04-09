/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.external_content_providers;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.external_content_provider;
import uim.platform.workzone.domain.ports.repositories.external_content_providers;

// import std.algorithm : filter;
// import std.array : array;

class MemoryExternalContentProviderRepository : ExternalContentProviderRepository {
  private ExternalContentProvider[ExternalContentProviderId] store;

  ExternalContentProvider[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(p => p.tenantId == tenantId).array;
  }

  ExternalContentProvider* findById(ExternalContentProviderId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ExternalContentProvider[] findByStatus(ProviderStatus status, TenantId tenantId) {
    return store.byValue().filter!(p => p.tenantId == tenantId && p.status == status).array;
  }

  void save(ExternalContentProvider provider) {
    store[provider.id] = provider;
  }

  void update(ExternalContentProvider provider) {
    store[provider.id] = provider;
  }

  void remove(ExternalContentProviderId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
