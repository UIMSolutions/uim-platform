/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.schema;

// import uim.platform.hana.application.usecases.manage.schemas;
// import uim.platform.hana.application.dto;
// import uim.platform.hana.presentation.http.json_utils;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class SchemaController : PlatformController {
  private ManageSchemasUseCase uc;

  this(ManageSchemasUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/schemas", &handleList);
    router.get("/api/v1/hana/schemas/*", &handleGet);
    router.post("/api/v1/hana/schemas", &handleCreate);
    router.put("/api/v1/hana/schemas/*", &handleUpdate);
    router.delete_("/api/v1/hana/schemas/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateSchemaRequest r;
      r.tenantId = req.getTenantId;
      r.instanceId = j.getString("instanceId");
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.owner = j.getString("owner");
      r.type = j.getString("type");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Schema created");

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
      auto schemas = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (s; schemas) {
        jarr ~= Json.emptyObject
        .set("id", s.id)
        .set("instanceId", s.instanceId)
        .set("name", s.name)
        .set("owner", s.owner)
        .set("tableCount", s.tableCount)
        .set("viewCount", s.viewCount)
        .set("sizeBytes", s.sizeBytes)
        .set("createdAt", s.createdAt);
      }

      auto resp = Json.emptyObject
        .set("count", schemas.length)
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
      auto s = uc.getById(id);
      if (s.isNull) {
        writeError(res, 404, "Schema not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", s.id)
        .set("instanceId", s.instanceId)
        .set("name", s.name)
        .set("owner", s.owner)
        .set("tableCount", s.tableCount)
        .set("viewCount", s.viewCount)
        .set("procedureCount", s.procedureCount)
        .set("sizeBytes", s.sizeBytes)
        .set("createdAt", s.createdAt)
        .set("updatedAt", s.updatedAt);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto j = req.json;
      UpdateSchemaRequest r;
      r.tenantId = req.getTenantId;
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.owner = j.getString("owner");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Schema updated");

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
