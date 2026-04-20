/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.external_content_provider;

import uim.platform.workzone.domain.types;

/// An external content provider — integration connector for third-party content sources.
struct ExternalContentProvider {
  mixin TenantEntity!(ExternalContentProviderId);

  string name;
  string description;
  ProviderType providerType = ProviderType.rest;
  ProviderStatus status = ProviderStatus.disconnected;
  string endpointUrl;
  string authType; // "none", "bearer", "oauth2", "basic"
  string authConfig; // JSON config reference
  string[] contentTypes; // types of content provided
  int refreshIntervalSec;
  long lastSyncAt;
  
  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("providerType", providerType.toString())
      .set("status", status.toString())
      .set("endpointUrl", endpointUrl)
      .set("authType", authType)
      .set("authConfig", authConfig)
      .set("contentTypes", contentTypes.array)
      .set("refreshIntervalSec", refreshIntervalSec)
      .set("lastSyncAt", lastSyncAt);
  }
}
