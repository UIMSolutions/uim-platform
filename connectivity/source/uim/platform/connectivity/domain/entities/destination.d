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
}

/// Named connectivity endpoint for reaching remote services.
struct Destination {
  DestinationId id;
  TenantId tenantId;
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

  // Metadata
  string createdBy;
  long createdAt;
  long updatedAt;
}
