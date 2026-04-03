/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.content_provider;

import uim.platform.portal.domain.types;

/// Content provider — source of apps and content.
struct ContentProvider
{
  ProviderId id;
  TenantId tenantId;
  string name;
  string description;
  ProviderType providerType = ProviderType.local;
  string contentEndpointUrl; // URL for federated/remote content
  string authToken; // bearer token for remote providers
  bool active = true;
  CatalogId[] catalogIds;
  long createdAt;
  long updatedAt;
  long lastSyncedAt;
}
