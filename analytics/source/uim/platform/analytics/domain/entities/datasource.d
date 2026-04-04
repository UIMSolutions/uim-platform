/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.entities.datasource;

import uim.platform.analytics.domain.values.common;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:

/// Represents an external data connection (database, file, API, live connection).
class DataSource {
  EntityId id;
  string name;
  DataSourceType sourceType;
  ConnectionInfo connection;
  ImportSchedule schedule;
  DataSourceStatus connStatus;
  AuditInfo audit;

  this()
  {
  }

  static DataSource create(string name, DataSourceType sourceType,
      ConnectionInfo conn, string userId)
  {
    auto ds = new DataSource();
    ds.id = EntityId.generate();
    ds.name = name;
    ds.sourceType = sourceType;
    ds.connection = conn;
    ds.schedule = ImportSchedule.init;
    ds.connStatus = DataSourceStatus.Disconnected;
    ds.audit = AuditInfo.create(userId);
    return ds;
  }

  void markConnected()
  {
    connStatus = DataSourceStatus.Connected;
  }

  void markError(string msg)
  {
    connStatus = DataSourceStatus.Error;
    connection.lastError = msg;
  }
}

enum DataSourceType {
  Database,
  CSV,
  Excel,
  OData,
  RestAPI,
  HANA,
  S3,
  GoogleSheets,
  LiveConnection,
}

enum DataSourceStatus {
  Connected,
  Disconnected,
  Error,
  Importing,
}

struct ConnectionInfo {
  string host;
  int port;
  string databaseName;
  string username;
  /// Not persisted — only used during connection setup
  string lastError;
}

struct ImportSchedule {
  bool enabled = false;
  string cronExpression = "";
  string timezone = "UTC";
}
