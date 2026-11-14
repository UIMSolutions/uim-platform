/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.content_provider;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// A content provider — source of catalogs and apps (local, remote content
/// endpoint or federated launchpad). Credentials are never stored here: remote
/// providers reference a BTP destination by name.
struct ContentProvider {
  mixin TenantEntity!ContentProviderId;

  string name;
  string description;
  ProviderType providerType = ProviderType.local;
  /// Content endpoint (remote / federated providers).
  string contentEndpointUrl;
  /// BTP destination holding URL and credentials of the endpoint.
  string destinationName;
  ProviderStatus status = ProviderStatus.active;
  long lastSyncedAt;
  string lastSyncMessage;
}
