/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.ports.repositories.providers;

// import uim.platform.portal.domain.entities.content_provider;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Port: outgoing — content provider persistence.
interface ProviderRepository : ITenantRepository!(ContentProvider, ProviderId) {

  bool existsByName(string name);
  ContentProvider findByName(string name);
  void removeByName(string name);

  size_t countByType(TenantId tenantId, ProviderType type);
  ContentProvider[] findByType(TenantId tenantId, ProviderType type);
  void removeByType(TenantId tenantId, ProviderType type);

}
