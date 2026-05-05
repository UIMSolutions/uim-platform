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

  Json toJson() const {
    return Json.emptyObject
      .set("minConnections", minConnections)
      .set("maxConnections", maxConnections)
      .set("idleTimeoutSeconds", idleTimeoutSeconds)
      .set("connectionTimeoutSeconds", connectionTimeoutSeconds);

  }
}

struct DatabaseConnection {
  mixin TenantEntity!(DatabaseConnectionId);

  DatabaseInstanceId instanceId;
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

  Json toJson() const {
    return entityToJson
      .set("instanceId", instanceId.value)
      .set("name", name)
      .set("description", description)
      .set("type", type.toString())
      .set("status", status.toString())
      .set("host", host)
      .set("port", port)
      .set("database", database)
      .set("user", user)
      .set("useTls", useTls)
      .set("tlsCertificate", tlsCertificate)
      .set("poolConfig", poolConfig.toJson())
      .set("properties", properties.array);
  }
}
