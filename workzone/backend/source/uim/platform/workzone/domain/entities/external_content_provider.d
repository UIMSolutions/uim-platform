/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.external_content_provider;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// An external content source (OData, REST, GraphQL, SAP BTP) federated into the workzone.
struct ExternalContentProvider {
  mixin TenantEntity!ExternalContentProviderId;

  string name; /// unique per tenant
  string description;
  ProviderType providerType = ProviderType.rest;
  ProviderStatus status = ProviderStatus.disconnected;
  string statusMessage;
  string endpointUrl;
  string authType = "none";
  string authConfig; /// secret (credentials / token reference)
  string[] contentTypes;
  int refreshIntervalSec = 3600; /// 0 = manual sync only
  long lastSyncAt;
  int itemCount;
}
