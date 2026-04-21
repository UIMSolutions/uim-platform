/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.repositories.content_providers;

// import uim.platform.content_agent.domain.entities.content_provider;
// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// Port: outgoing - content provider persistence.
interface ContentProviderRepository : ITenantRepository!(ContentProvider, ContentProviderId) {

  bool existsByName(TenantId tenantId, string name);
  ContentProvider findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

  size_t countByStatus(TenantId tenantId, ProviderStatus status);
  ContentProvider[] findByStatus(TenantId tenantId, ProviderStatus status);
  void removeByStatus(TenantId tenantId, ProviderStatus status);

}
