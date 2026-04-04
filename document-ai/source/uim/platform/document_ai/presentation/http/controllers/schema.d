/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.schema;

import uim.platform.document_ai.application.use_cases.manage_schemas;
import uim.platform.document_ai.application.dto;
import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.schema : Schema;
import uim.platform.document_ai.presentation.http.json_utils;

import uim.platform.document_ai;

class SchemaController : SAPController {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.clientId = req.headers.get("X-Client-Id", "");
      r.documentTypeId = jsonStr(j, "documentTypeId");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.headerFields = jsonFieldArray(j, "headerFields");
      r.lineItemFields = jsonFieldArray(j, "lineItemFields");
      r.supportedLanguages = jsonStrArray(j, "supportedLanguages");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Schema created");
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
      foreach (ref s; schemas) {
        jarr ~= schemaToJson(s);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) schemas.length);
      resp["resources"] = jarr;
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

      auto s = uc.get_(id, clientId);
      if (s.id.length == 0) {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.clientId = req.headers.get("X-Client-Id", "");
      r.schemaId = id;
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.status = jsonStr(j, "status");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Schema updated");
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

  private Json schemaToJson(ref Schema s) {
    import std.conv : to;

    auto sj = Json.emptyObject;
    sj["id"] = Json(s.id);
    sj["documentTypeId"] = Json(s.documentTypeId);
    sj["name"] = Json(s.name);
    sj["description"] = Json(s.description);
    sj["status"] = Json(s.status.to!string);
    sj["createdAt"] = Json(s.createdAt);
    sj["modifiedAt"] = Json(s.modifiedAt);

    auto hArr = Json.emptyArray;
    foreach (ref f; s.headerFields) {
      auto fj = Json.emptyObject;
      fj["name"] = Json(f.name);
      fj["label"] = Json(f.label);
      fj["type"] = Json(f.type.to!string);
      fj["required"] = Json(f.required);
      hArr ~= fj;
    }
    sj["headerFields"] = hArr;

    auto liArr = Json.emptyArray;
    foreach (ref f; s.lineItemFields) {
      auto fj = Json.emptyObject;
      fj["name"] = Json(f.name);
      fj["label"] = Json(f.label);
      fj["type"] = Json(f.type.to!string);
      fj["required"] = Json(f.required);
      liArr ~= fj;
    }
    sj["lineItemFields"] = liArr;

    sj["supportedLanguages"] = toJsonArray(s.supportedLanguages);

    return sj;
  }
}
