module uim.platform.xyz.domain.entities.destination;

import uim.platform.xyz.domain.types;

/// A destination configuration — defines how to connect to a target system
/// for automated step execution. Mirrors SAP BTP destination service concepts.
struct Destination {
  DestinationId id;
  TenantId tenantId;
  string name; // unique destination name
  string description;
  SystemId systemId; // linked system connection
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
  string createdBy;
  long createdAt;
  long updatedAt;
}
