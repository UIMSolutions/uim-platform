/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.web.handlers.datasource;

// import uim.platform.analytics.app.usecases.datasources;
// import uim.platform.analytics.app.dto.datasource;

import uim.platform.analytics;

mixin(ShowModule!());
@safe:

class DataSourceHandler {
  private DataSourceUseCases useCases;

  this(DataSourceUseCases useCases) {
    this.useCases = useCases;
  }

  void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto items = useCases.listSources(TenantId.init);
    Json jArr = Json.emptyArray;
    foreach (item; items) jArr ~= toJsonValue(item);
    res.writeJsonBody(jArr);
  }

  void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI);
    if (id.length == 0) {
      res.writeJsonBody(errorJson("Missing id"), 400);
      return;
    }
    auto item = useCases.getSource(TenantId.init, DataSourceId(id));
    if (item.id.isNull) {
      res.writeJsonBody(errorJson("Not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(item));
  }

  void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      DataSourceType srcType;
      try {
        srcType = json["sourceType"].get!string.to!DataSourceType;
      } catch (Exception) {
        srcType = DataSourceType.Database;
      }
      auto cmd = CreateDataSourceRequest(json["name"].get!string, srcType,
          json["host"].get!string, json["port"].get!int,
          json["databaseName"].get!string, json["username"].get!string,
          UserId(json["userId"].get!string));
      res.writeJsonBody(toJsonValue(useCases.createSource(cmd)), 201);
    }
    catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), 400);
    }
  }

  void testConn(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI);
    auto result = useCases.testConnection(TenantId.init, DataSourceId(id));
    if (result.id.isNull) {
      res.writeJsonBody(errorJson("Not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(result));
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI);
    useCases.deleteSource(TenantId.init, DataSourceId(id));
    res.writeJsonBody(Json.emptyObject, 204);
  }
}

