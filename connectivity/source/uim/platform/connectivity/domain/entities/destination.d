/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.entities.destination;

// import uim.platform.connectivity.domain.types;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// Custom property key-value pair attached to a destination.
struct DestinationProperty {
  string key;
  string value;

  Json toJson() const {
    return Json.emptyObject
        .set("key", key)
        .set("value", value);
  }
}

/// Named connectivity endpoint for reaching remote services.
struct Destination {
  mixin TenantEntity!(DestinationId);

  string name;
  string description;
  string url;
  DestinationType destinationType = DestinationType.http;
  AuthenticationType authType = AuthenticationType.noAuthentication;
  ProxyType proxyType = ProxyType.internet;

  // Authentication details (stored fields; actual secrets handled by adapter)
  string user;
  string password; // plaintext never exposed via API
  string clientId;
  string clientSecret;
  string tokenServiceUrl;
  string tokenServiceUser;
  string tokenServicePassword;
  CertificateId certificateId;

  // Proxy / Cloud Connector
  string cloudConnectorLocationId;

  // Custom properties & headers
  DestinationProperty[] properties;
  DestinationProperty[] additionalHeaders;

  Json toJson() const {
    return entityToJson
        .set("name", name)
        .set("description", description)
        .set("url", url)
        .set("destinationType", destinationType.to!string)
        .set("authType", authType.to!string)
        .set("proxyType", proxyType.to!string)
        .set("properties", properties.map!(p => p.toJson()).array.toJson)
        .set("additionalHeaders", additionalHeaders.map!(h => h.toJson()).array.toJson)
        .set("certificateId", certificateId.value)
        .set("cloudConnectorLocationId", cloudConnectorLocationId)
        .set("hasCredentials", user.length > 0 || password.length > 0 || clientId.length > 0 || clientSecret.length > 0)
        .set("hasTokenService", tokenServiceUrl.length > 0)
        .set("tokenServiceUser", tokenServiceUser.length > 0)
        .set("tokenServicePassword", tokenServicePassword.length > 0);
  }
}
