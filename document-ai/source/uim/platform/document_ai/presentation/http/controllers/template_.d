/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.template_;

import uim.platform.document_ai.application.usecases.manage.templates;
import uim.platform.document_ai.application.dto;
import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.template_ : Template;
import uim.platform.document_ai.presentation.http.json_utils;

import uim.platform.document_ai;

class TemplateController : PlatformController {
  private ManageTemplatesUseCase uc;

  this(ManageTemplatesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/templates", &handleCreate);
    router.get("/api/v1/templates", &handleList);
    router.get("/api/v1/templates/*", &handleGet);
    router.put("/api/v1/templates/*", &handleUpdate);
    router.delete_("/api/v1/templates/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateTemplateRequest r;
      r.tenantId = req.getTenantId;
      r.clientId = req.headers.get("X-Client-Id", "");
      r.schemaId = j.getString("schemaId");
      r.documentTypeId = j.getString("documentTypeId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.regions = jsonRegionArray(j, "regions");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Template created");
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
      auto templates = uc.list(clientId);

      auto jarr = Json.emptyArray;
      foreach (t; templates) {
        jarr ~= templateToJson(t);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) templates.length);
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

      auto t = uc.get_(id, clientId);
      if (t.id.isEmpty) {
        writeError(res, 404, "Template not found");
        return;
      }

      res.writeJsonBody(templateToJson(t), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;

      UpdateTemplateRequest r;
      r.tenantId = req.getTenantId;
      r.clientId = req.headers.get("X-Client-Id", "");
      r.templateId = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.status = j.getString("status");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Template updated");
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

  private Json templateToJson(Template t) {
    import std.conv : to;

    auto tj = Json.emptyObject;
    tj["id"] = Json(t.id);
    tj["schemaId"] = Json(t.schemaId);
    tj["documentTypeId"] = Json(t.documentTypeId);
    tj["name"] = Json(t.name);
    tj["description"] = Json(t.description);
    tj["status"] = Json(t.status.to!string);
    tj["createdAt"] = Json(t.createdAt);
    tj["modifiedAt"] = Json(t.modifiedAt);

    auto rArr = Json.emptyArray;
    foreach (r; t.regions) {
      auto rj = Json.emptyObject;
      rj["fieldName"] = Json(r.fieldName);
      rj["page"] = Json(cast(long) r.page);
      rj["x"] = Json(r.x);
      rj["y"] = Json(r.y);
      rj["width"] = Json(r.width);
      rj["height"] = Json(r.height);
      rArr ~= rj;
    }
    tj["regions"] = rArr;

    return tj;
  }
}
