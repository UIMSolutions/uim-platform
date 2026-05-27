/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.schema;
// import uim.platform.hana.application.usecases.manage.schemas;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class SchemaController : ManageController {
  private ManageSchemasUseCase usecase;

  this(ManageSchemasUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/schemas", &handleList);
    router.get("/api/v1/hana/schemas/*", &handleGet);
    router.post("/api/v1/hana/schemas", &handleCreate);
    router.put("/api/v1/hana/schemas/*", &handleUpdate);
    router.delete_("/api/v1/hana/schemas/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      CreateSchemaRequest r;
      r.tenantId = tenantId;
      r.instanceId = j.getString("instanceId");
      r.id = precheck.id;
      r.name = j.getString("name");
      r.owner = j.getString("owner");
      r.type = j.getString("type");

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Schema created");

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
      auto schemas = usecase.list(tenantId);

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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto s = usecase.getById(tenantId, id);
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

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      

      auto j = req.json;
      UpdateSchemaRequest r;
      r.tenantId = tenantId;
      r.id = precheck.id;
      r.owner = j.getString("owner");

      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Schema updated");

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
      auto id = Schemaprecheck.id);
      auto result = usecase.deleteSchema(id);
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
