/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.external_content_providers;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.external_content_provider;
// import uim.platform.workzone.domain.ports.repositories.external_content_providers;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
// import std.algorithm : filter;
// import std.array : array;

class MemoryExternalContentProviderRepository : TenantRepository!(ExternalContentProvider, ExternalContentProviderId), ExternalContentProviderRepository {

  size_t countByStatus(TenantId tenantId, ProviderStatus status) {
    return findByStatus(tenantId, status).length;
  }

  ExternalContentProvider[] findByStatus(TenantId tenantId, ProviderStatus status) {
    return findByTenant(tenantId).filter!(p => p.status == status).array;
  }

  void removeByStatus(TenantId tenantId, ProviderStatus status) {
    findByStatus(tenantId, status).each!(p => remove(p));
  } 
}
