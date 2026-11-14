/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.entities.destination;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// A named endpoint of a remote service (SAP BTP Destination service).
/// Secrets are stored here; driving adapters mask them on output.
struct Destination {
  mixin TenantEntity!DestinationId;

  string name; /// unique per tenant, e.g. "S4_ONPREM_ODATA"
  string description;
  string url;
  DestinationType destinationType = DestinationType.http;
  AuthenticationType authenticationType = AuthenticationType.noAuthentication;
  ProxyType proxyType = ProxyType.internet;

  // Credentials (secrets)
  string user;
  string password;
  string clientId;
  string clientSecret;
  string tokenServiceUrl;
  string tokenServiceUser;
  string tokenServicePassword;
  CertificateId certificateId; /// client certificate (mTLS) / signing key

  // Routing
  string cloudConnectorLocationId; /// on-premise: location of the Cloud Connector ("" = default)

  KeyValue[] properties; /// additional properties, e.g. sap-client=100
  KeyValue[] additionalHeaders; /// HTTP headers sent with every request

  // Last connection check
  DestinationStatus status = DestinationStatus.unchecked;
  string statusMessage;
  long lastCheckedAt;
  int latencyMs;
}
