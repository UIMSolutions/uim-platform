/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.entities.content_provider;

import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// Describes a content type offered by a provider.
struct ProvidedContentType {
  ContentTypeId typeId;
  string name;
  ContentCategory category;
  string description;
  string version_;
}

/// A registered content provider from which content can be discovered and assembled.
struct ContentProvider {
  TenantId tenantId;
  ContentProviderId id;
  string name;
  string description;
  string endpoint;
  string authToken;
  ProviderStatus status = ProviderStatus.active;
  ProvidedContentType[] contentTypes;
  string createdBy;
  long registeredAt;
  long lastSyncAt;
}
