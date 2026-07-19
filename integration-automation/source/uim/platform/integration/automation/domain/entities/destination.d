/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.entities.destination;

import uim.platform.integration.automation;
mixin(ShowModule!());

@safe:
/// A destination configuration — defines how to connect to a target system
/// for automated step execution. Mirrors SAP BTP destination service concepts.
struct Destination {
  mixin TenantEntity!DestinationId;
  
  string name; // unique destination name
  string description;
  SystemConnectionId systemId; // linked system connection
  DestinationType destinationType;
  string url; // full URL for the destination
  AuthenticationType authenticationType;
  ProxyType proxyType = ProxyType.internet;
  string cloudConnectorLocationId; // for on-premise routing
  string user; // basic auth user (encrypted at rest)
  string tokenServiceUrl; // OAuth token endpoint
  string tokenServiceUser;
  string audience;
  string scope_; // OAuth scope
  bool isEnabled = true;

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("systemId", systemId)
      .set("destinationType", destinationType.to!string())
      .set("url", url)
      .set("authenticationType", authenticationType.to!string())
      .set("proxyType", proxyType.to!string())
      .set("cloudConnectorLocationId", cloudConnectorLocationId)
      .set("user", user) // consider masking in real implementation
      .set("tokenServiceUrl", tokenServiceUrl)
      .set("tokenServiceUser", tokenServiceUser)
      .set("audience", audience)
      .set("scope", scope_)
      .set("isEnabled", isEnabled);
  }
}
