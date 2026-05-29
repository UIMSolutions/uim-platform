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

class DatabaseConnectionController : ManageController {
  private ManageDatabaseConnectionsUseCase usecase;

  this(ManageDatabaseConnectionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/connections", &handleList);
    router.get("/api/v1/hana/connections/*", &handleGet);
    router.post("/api/v1/hana/connections", &handleCreate);
    router.put("/api/v1/hana/connections/*", &handleUpdate);
    router.delete_("/api/v1/hana/connections/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateDatabaseConnectionRequest r;
      r.tenantId = tenantId;
      r.instanceId = data.getString("instanceId");
      r.id = precheck.id;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.type = data.getString("type");
      r.host = data.getString("host");
      r.port = data.getInteger("port", 443);
      r.database = data.getString("database");
      r.user = data.getString("user");
      r.password = data.getString("password");
      r.useTls = data.getBoolean("useTls", true);
      r.minConnections = data.getInteger("minConnections", 1);
      r.maxConnections = data.getInteger("maxConnections", 10);
      r.properties = jsonKeyValuePairs(j, "properties");

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Database connection created");
        
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto conns = usecase.list(tenantId);

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
        .set("resources", list);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto c = usecase.getById(tenantId, id);
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

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      

      auto data = precheck.data;
      UpdateDatabaseConnectionRequest r;
      r.tenantId = tenantId;
      r.id = precheck.id;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.host = data.getString("host");
      r.port = data.getInteger("port", 443);
      r.database = data.getString("database");
      r.user = data.getString("user");
      r.password = data.getString("password");

      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Database connection updated");
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = DatabaseConnectionId(precheck.id);
      auto result = usecase.deleteDatabaseConnection(id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
