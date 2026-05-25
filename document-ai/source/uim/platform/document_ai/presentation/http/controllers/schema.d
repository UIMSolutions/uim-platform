/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.schema;
// import uim.platform.document_ai.application.usecases.manage.schemas;
// import uim.platform.document_ai.application.dto;
// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.schema : Schema;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class SchemaController : ManageController {
  private ManageSchemasUseCase usecase;

  this(ManageSchemasUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/schemas", &handleCreate);
    router.get("/api/v1/schemas", &handleList);
    router.get("/api/v1/schemas/*", &handleGet);
    router.put("/api/v1/schemas/*", &handleUpdate);
    router.delete_("/api/v1/schemas/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateSchemaRequest r;
      r.tenantId = tenantId;
      r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
      r.documentTypeId = j.getString("documentTypeId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.headerFields = jsonFieldArray(j, "headerFields");
      r.lineItemFields = jsonFieldArray(j, "lineItemFields");
      r.supportedLanguages = getStrings(j, "supportedLanguages");

      auto result = usecase.create(r);
      if (result.success) {
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
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));
      auto schemas = usecase.list(clientId);

      auto jarr = Json.emptyArray;
      foreach (s; schemas) {
        jarr ~= schemaToJson(s);
      }

      auto resp = Json.emptyObject
        .set("count", Json(schemas.length))
        .set("resources", jarr)
        .set("message", "Schema list retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

      auto s = usecase.getById(id, clientId);
      if (s.isNull) {
        writeError(res, 404, "Schema not found");
        return;
      }

      res.writeJsonBody(schemaToJson(s), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;

      UpdateSchemaRequest r;
      r.tenantId = tenantId;
      r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
      r.schemaId = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.status = j.getString("status");

      auto result = usecase.update(r);
      if (result.success) {
        auto resp = Json.emptyObject  
          .set("id", result.id)
          .set("message", "Schema updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

      auto result = usecase.deleteSchema(SchemaId(id), clientId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json schemaToJson(Schema s) {
    

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
