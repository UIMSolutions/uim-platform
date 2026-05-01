/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.schema;

import uim.platform.document_ai.application.usecases.manage.schemas;
import uim.platform.document_ai.application.dto;
import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.schema : Schema;

import uim.platform.document_ai;

class SchemaController : PlatformController {
  private ManageSchemasUseCase uc;

  this(ManageSchemasUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/schemas", &handleCreate);
    router.get("/api/v1/schemas", &handleList);
    router.get("/api/v1/schemas/*", &handleGet);
    router.put("/api/v1/schemas/*", &handleUpdate);
    router.delete_("/api/v1/schemas/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateSchemaRequest r;
      r.tenantId = req.getTenantId;
      r.clientId = req.headers.get("X-Client-Id", "");
      r.documentTypeId = j.getString("documentTypeId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.headerFields = jsonFieldArray(j, "headerFields");
      r.lineItemFields = jsonFieldArray(j, "lineItemFields");
      r.supportedLanguages = getStringArray(j, "supportedLanguages");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", Json("Schema created"));

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
      auto clientId = req.headers.get("X-Client-Id", "");
      auto schemas = uc.list(clientId);

      auto jarr = Json.emptyArray;
      foreach (s; schemas) {
        jarr ~= schemaToJson(s);
      }

      auto resp = Json.emptyObject
        .set("count", Json(schemas.length))
        .set("resources", jarr)
        .set("message", Json("Schema list retrieved successfully"));

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto clientId = req.headers.get("X-Client-Id", "");

      auto s = uc.getById(id, clientId);
      if (s.isNull) {
        writeError(res, 404, "Schema not found");
        return;
      }

      res.writeJsonBody(schemaToJson(s), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;

      UpdateSchemaRequest r;
      r.tenantId = req.getTenantId;
      r.clientId = req.headers.get("X-Client-Id", "");
      r.schemaId = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.status = j.getString("status");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject  
          .set("id", Json(result.id))
          .set("message", Json("Schema updated"));

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto clientId = req.headers.get("X-Client-Id", "");

      auto result = uc.remove(id, clientId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json schemaToJson(Schema s) {
    import std.conv : to;

    auto sj = Json.emptyObject
      .set("id", s.id)
      .set("documentTypeId", s.documentTypeId)
      .set("name", s.name)
      .set("description", s.description)
      .set("status", s.status.to!string)
      .set("createdAt", s.createdAt)
      .set("updatedAt", s.updatedAt);

    auto hArr = Json.emptyArray;
    foreach (f; s.headerFields) {
      hArr ~= Json.emptyObject
        .set("name", f.name)
        .set("label", f.label)
        .set("type", f.type.to!string)
        .set("required", f.required);
    }
    sj["headerFields"] = hArr;

    auto liArr = Json.emptyArray;
    foreach (f; s.lineItemFields) {
      liArr ~= Json.emptyObject
        .set("name", f.name)
        .set("label", f.label)
        .set("type", f.type.to!string)
        .set("required", f.required);
    }
    sj["lineItemFields"] = liArr;

    sj["supportedLanguages"] = toJsonArray(s.supportedLanguages);

    return sj;
  }
}
