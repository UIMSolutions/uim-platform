/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.dto.datasource;

// import std.conv : to;
import uim.platform.analytics.domain.entities.datasource;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
struct CreateDataSourceRequest {
  string name;
  string sourceType;
  string host;
  int port;
  string databaseName;
  string username;
  string userId;
}

struct DataSourceResponse {
  string id;
  string name;
  string sourceType;
  string host;
  int port;
  string databaseName;
  string status;

  static DataSourceResponse fromEntity(DataSource ds)
  {
    if (ds is null)
      return DataSourceResponse.init;

    return DataSourceResponse(ds.id.value, ds.name, ds.sourceType.to!string,
        ds.connection.host, ds.connection.port, ds.connection.databaseName,
        ds.connStatus.to!string,);
  }
}
