/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module presentation.http.transformation;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_transformations;
import application.dto;
import domain.entities.transformation;
import domain.types;
import presentation.http.json_utils;

class TransformationController {
  private ManageTransformationsUseCase uc;

  this(ManageTransformationsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/transformations", &handleCreate);
    router.get("/api/v1/transformations", &handleList);
    router.get("/api/v1/transformations/*", &handleGetById);
    router.put("/api/v1/transformations/*", &handleUpdate);
    router.delete_("/api/v1/transformations/*", &handleDelete);
    router.post("/api/v1/transformations/test", &handleTest);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateTransformationRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.systemId = j.getString("systemId");
      r.systemRole = parseSystemRole(j.getString("systemRole"));
      r.name = j.getString("name");
      r.mappingRules = j.getString("mappingRules");
      r.conditions = j.getString("conditions");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createTransformation(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listTransformations(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref t; items)
        arr ~= serializeTransformation(t);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long)items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto t = uc.getTransformation(id, tenantId);
      if (t is null) {
        writeError(res, 404, "Transformation not found");
        return;
      }
      res.writeJsonBody(serializeTransformation(*t), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateTransformationRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.mappingRules = j.getString("mappingRules");
      r.conditions = j.getString("conditions");

      auto result = uc.updateTransformation(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.error == "Transformation not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleTest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto systemId = j.getString("systemId");
      auto inputAttributes = j.getString("inputAttributes");

      if (systemId.length == 0 || inputAttributes.length == 0) {
        writeError(res, 400, "systemId and inputAttributes are required");
        return;
      }

      auto output = uc.testTransformation(inputAttributes, systemId, tenantId);
      auto resp = Json.emptyObject;
      resp["output"] = Json(output);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.deleteTransformation(id, tenantId);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeTransformation(ref const Transformation t) {
    auto j = Json.emptyObject;
    j["id"] = Json(t.id);
    j["tenantId"] = Json(t.tenantId);
    j["systemId"] = Json(t.systemId);
    j["systemRole"] = Json(t.systemRole.to!string);
    j["name"] = Json(t.name);
    j["mappingRules"] = Json(t.mappingRules);
    j["conditions"] = Json(t.conditions);
    j["createdBy"] = Json(t.createdBy);
    j["createdAt"] = Json(t.createdAt);
    j["updatedAt"] = Json(t.updatedAt);
    return j;
  }
}
