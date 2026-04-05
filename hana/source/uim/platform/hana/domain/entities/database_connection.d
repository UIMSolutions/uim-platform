/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.entities.database_connection;

// import uim.platform.hana.domain.types;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
struct ConnectionPoolConfig {
  int minConnections;
  int maxConnections;
  int idleTimeoutSeconds;
  int connectionTimeoutSeconds;
}

struct DatabaseConnection {
  DatabaseConnectionId id;
  TenantId tenantId;
  InstanceId instanceId;
  string name;
  string description;
  ConnectionType type;
  ConnectionStatus status;
  string host;
  int port;
  string database;
  string user;
  bool useTls;
  string tlsCertificate;
  ConnectionPoolConfig poolConfig;
  string[][] properties;
  long createdAt;
  long modifiedAt;
}
