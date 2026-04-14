/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.client;

import uim.platform.document_ai.application.usecases.manage.clients;
import uim.platform.document_ai.application.dto;
import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.client : Client;
import uim.platform.document_ai.presentation.http.json_utils;

import uim.platform.document_ai;

class ClientController : PlatformController {
  private ManageClientsUseCase uc;

  this(ManageClientsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/admin/clients", &handleCreate);
    router.get("/api/v1/admin/clients", &handleList);
    router.get("/api/v1/admin/clients/*", &handleGet);
    router.patch_("/api/v1/admin/clients/*", &handlePatch);
    router.delete_("/api/v1/admin/clients/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateClientRequest r;
      r.tenantId = req.getTenantId;
      r.clientName = j.getString("clientName");
      r.description = j.getString("description");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["clientId"] = Json(result.id);
        resp["message"] = Json("Client created");
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
      auto clients = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (c; clients) {
        jarr ~= clientToJson(c);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(clients.length);
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
      TenantId tenantId = req.getTenantId;

      auto c = uc.get_(tenantId, id);
      if (c.clientId.isEmpty) {
        writeError(res, 404, "Client not found");
        return;
      }

      res.writeJsonBody(clientToJson(c), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;

      PatchClientRequest r;
      r.tenantId = req.getTenantId;
      r.clientId = id;
      r.clientName = j.getString("clientName");
      r.description = j.getString("description");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["clientId"] = Json(result.id);
        resp["message"] = Json("Client updated");
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
      TenantId tenantId = req.getTenantId;

      auto result = uc.remove(tenantId, id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json clientToJson(Client c) {
    return Json.emptyObject
      .set("clientId", Json(c.clientId))
      .set("tenantId", Json(c.tenantId))
      .set("clientName", Json(c.clientName))
      .set("description", Json(c.description))
      .set("isActive", Json(c.isActive))
      .set("createdAt", Json(c.createdAt))
      .set("modifiedAt", Json(c.modifiedAt));
  }
}
