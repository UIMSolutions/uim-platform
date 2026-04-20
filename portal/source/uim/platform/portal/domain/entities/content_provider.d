/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.content_provider;

// mport uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Content provider — source of apps and content.
struct ContentProvider {
  mixin TenantEntity!(ProviderId);

  string name;
  string description;
  ProviderType providerType = ProviderType.local;
  string contentEndpointUrl; // URL for federated/remote content
  string authToken; // bearer token for remote providers
  bool active = true;
  CatalogId[] catalogIds;
  long lastSyncedAt;

  Json toJson() const {
    auto j = entityToJson
      .set("name", name)
      .set("description", description)
      .set("providerType", providerType.toString())
      .set("contentEndpointUrl", contentEndpointUrl)
      .set("active", active)
      .set("catalogIds", catalogIds.map!(id => id.value).array)
      .set("lastSyncedAt", lastSyncedAt);

    return j;
  }
}
