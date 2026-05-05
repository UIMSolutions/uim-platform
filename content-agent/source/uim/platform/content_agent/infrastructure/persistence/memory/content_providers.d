/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.infrastructure.persistence.memory.content_providers;

// import uim.platform.content_agent.domain.types;
// import uim.platform.content_agent.domain.entities.content_provider;
// import uim.platform.content_agent.domain.ports.repositories.content_providers;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
class MemoryContentProviderRepository : TenantRepository!(ContentProvider, ContentProviderId), ContentProviderRepository {

  // #region byName
  bool existsByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return true;
    return false;
  }

  ContentProvider findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return ContentProvider.init;
  }

  void removeByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name) {
        remove(e.id);
        return;
      }
  }
  // #region byName
  
  // #region byStatus
  size_t countByStatus(TenantId tenantId, ProviderStatus status) {
    return findByStatus(tenantId, status).length;
  }

  ContentProvider[] findByStatus(TenantId tenantId, ProviderStatus status) {
    return findByTenant(tenantId).filter!(e => e.status == status).array;
  }

  void removeByStatus(TenantId tenantId, ProviderStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }
  // #endregion byStatus

}
