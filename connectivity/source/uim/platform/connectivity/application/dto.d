/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.dto;

// import uim.platform.connectivity.domain.types;
// import uim.platform.connectivity.domain.entities.destination : DestinationProperty;


import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// --- Destination DTOs ---

struct CreateDestinationRequest {
  TenantId tenantId;
  string name;
  string description;
  string url;
  string destinationType; // "http", "rfc", "mail", "ldap"
  string authType; // "noAuthentication", "basicAuthentication", ...
  string proxyType; // "internet", "onPremise", "privateLink"
  string user;
  string password;
  string clientId;
  string clientSecret;
  string tokenServiceUrl;
  string tokenServiceUser;
  string token;
  string tokenServicePassword;
  string certificateId;
  string cloudConnectorLocationId;
  DestinationProperty[] properties;
  DestinationProperty[] additionalHeaders;
}

struct UpdateDestinationRequest {
  string description;
  string url;
  string authType;
  string proxyType;
  string user;
  string password;
  string clientId;
  string clientSecret;
  string tokenServiceUrl;
  string tokenServiceUser;
  string tokenServicePassword;
  string certificateId;
  string cloudConnectorLocationId;
  DestinationProperty[] properties;
  DestinationProperty[] additionalHeaders;
}

/// --- Cloud Connector DTOs ---

struct RegisterConnectorRequest {
  SubaccountId subaccountId;
  TenantId tenantId;
  string locationId;
  string description;
  string connectorVersion;
  string host;
  ushort port;
  string tunnelEndpoint;
}

struct HeartbeatRequest {
  string connectorVersion;
}

/// --- Service Channel DTOs ---

struct CreateChannelRequest {
  ConnectorId connectorId;
  TenantId tenantId;
  string name;
  string channelType; // "http", "rfc", "tcp"
  string virtualHost;
  ushort virtualPort;
  string backendHost;
  ushort backendPort;
}

/// --- Access Rule DTOs ---

struct CreateAccessRuleRequest {
  ConnectorId connectorId;
  TenantId tenantId;
  string description;
  string protocol; // "http", "https", "rfc", "tcp", "ldap"
  string virtualHost;
  ushort virtualPort;
  string urlPathPrefix;
  string policy; // "allow", "deny"
  bool principalPropagation;

}

struct UpdateAccessRuleRequest {
  string description;
  string urlPathPrefix;
  string policy;
  string protocol;
  string virtualHost;
  ushort virtualPort;
  bool principalPropagation;
}

/// --- Certificate DTOs ---

struct CreateCertificateRequest {
  TenantId tenantId;
  string name;
  string description;
  string certType; // "x509", "pkcs12", "pem", "jks"
  string usage; // "authentication", "signing", "encryption"
  string subjectDN;
  string issuerDN;
  string serialNumber;
  string fingerprint;
  long validFrom;
  long validTo;
}

struct UpdateCertificateRequest {
  string description;
  bool active;
}
