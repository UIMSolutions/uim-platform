module uim.platform.xyz.domain.entities.system_connection;

import uim.platform.xyz.domain.types;

/// A system in the customer landscape — represents an endpoint
/// that participates in integration scenarios.
struct SystemConnection {
  SystemId id;
  TenantId tenantId;
  string name; // e.g. "Production S/4HANA"
  string description;
  SystemType systemType;
  string host;
  ushort port;
  string client; // SAP client number
  string protocol = "https";
  ConnectionStatus status = ConnectionStatus.inactive;
  string environment; // e.g. "production", "staging", "dev"
  string region; // e.g. "eu10", "us20"
  string systemId; // SAP SID
  string tenant; // subaccount / tenant identifier
  string createdBy;
  long createdAt;
  long updatedAt;
}
