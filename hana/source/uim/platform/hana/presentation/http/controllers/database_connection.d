/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.database_connection;

// import uim.platform.hana.application.usecases.manage.database_connections;
// import uim.platform.hana.application.dto;
import uim.platform.hana;

mixin(ShowModule!());

@safe:

class DatabaseConnectionController : PlatformController {
  private ManageDatabaseConnectionsUseCase uc;

  this(ManageDatabaseConnectionsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/connections", &handleList);
    router.get("/api/v1/hana/connections/*", &handleGet);
    router.post("/api/v1/hana/connections", &handleCreate);
    router.put("/api/v1/hana/connections/*", &handleUpdate);
    router.delete_("/api/v1/hana/connections/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDatabaseConnectionRequest r;
      r.tenantId = req.getTenantId;
      r.instanceId = j.getString("instanceId");
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.host = j.getString("host");
      r.port = j.getInteger("port", 443);
      r.database = j.getString("database");
      r.user = j.getString("user");
      r.password = j.getString("password");
      r.useTls = j.getBoolean("useTls", true);
      r.minConnections = j.getInteger("minConnections", 1);
      r.maxConnections = j.getInteger("maxConnections", 10);
      r.properties = jsonKeyValuePairs(j, "properties");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Database connection created");
        
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto conns = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (c; conns) {
        jarr ~= Json.emptyObject
          .set("id", c.id)
          .set("instanceId", c.instanceId)
          .set("name", c.name)
          .set("type", c.type.to!string)
          .set("status", c.status.to!string)
          .set("host", c.host)
          .set("port", c.port)
          .set("createdAt", c.createdAt);
      }

      auto resp = Json.emptyObject
        .set("count", Json(conns.length))
        .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto c = uc.getById(id);
      if (c.isNull) {
        writeError(res, 404, "Database connection not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", c.id)
        .set("instanceId", c.instanceId)
        .set("name", c.name)
        .set("description", c.description)
        .set("type", c.type.to!string)
        .set("status", c.status.to!string)
        .set("host", c.host)
        .set("port", c.port)
        .set("database", c.database)
        .set("user", c.user)
        .set("useTls", c.useTls)
        .set("createdAt", c.createdAt)
        .set("updatedAt", c.updatedAt);
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto j = req.json;
      UpdateDatabaseConnectionRequest r;
      r.tenantId = req.getTenantId;
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.host = j.getString("host");
      r.port = j.getInteger("port", 443);
      r.database = j.getString("database");
      r.user = j.getString("user");
      r.password = j.getString("password");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Database connection updated");
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = uc.removeById(id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
