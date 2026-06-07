/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.entities.datasource;

import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
/// Represents an external data connection (database, file, API, live connection).
struct DataSource {
  mixin TenantEntity!DataSourceId;
  string name;
  DataSourceType sourceType;
  ConnectionInfo connection;
  ImportSchedule schedule;
  DataSourceStatus connStatus;
  AuditInfo audit;

  static DataSource create(string name, DataSourceType sourceType,
      ConnectionInfo conn, UserId userId) {
    DataSource ds;
    ds.id = DataSourceId(EntityId.generate().value);
    ds.name = name;
    ds.sourceType = sourceType;
    ds.connection = conn;
    ds.schedule = ImportSchedule.init;
    ds.connStatus = DataSourceStatus.Disconnected;
    return ds;
  }

  void markConnected() {
    connStatus = DataSourceStatus.Connected;
  }

  void markError(string msg) {
    connStatus = DataSourceStatus.Error;
    connection.lastError = msg;
  }

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("sourceType", sourceType.to!string)
      .set("connection", connection.toJson())
      .set("schedule", schedule.toJson())
      .set("connStatus", connStatus.to!string);
  }
}



struct ConnectionInfo {
  string host;
  int port;
  string databaseName;
  string username;
  /// Not persisted — only used during connection setup
  string lastError;

  Json toJson() const {
    return Json.emptyObject
      .set("host", host)
      .set("port", port)
      .set("databaseName", databaseName)
      .set("username", username)
      .set("lastError", lastError);
  }
}

struct ImportSchedule {
  bool enabled = false;
  string cronExpression = "";
  string timezone = "UTC";

  Json toJson() const {
    return Json.emptyObject
      .set("enabled", enabled)
      .set("cronExpression", cronExpression)
      .set("timezone", timezone);
  }
}
