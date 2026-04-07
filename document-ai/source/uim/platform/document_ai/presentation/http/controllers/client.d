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

class ClientController : SAPController {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.clientName = j.getString("clientName");
      r.description = j.getString("description");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["clientId"] = Json(result.id);
        resp["message"] = Json("Client created");
        res.writeJsonBody(resp, 201);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto clients = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (ref c; clients) {
        jarr ~= clientToJson(c);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) clients.length);
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");

      auto c = uc.get_(id, tenantId);
      if (c.clientId.length == 0) {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.clientId = id;
      r.clientName = j.getString("clientName");
      r.description = j.getString("description");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["clientId"] = Json(result.id);
        resp["message"] = Json("Client updated");
        res.writeJsonBody(resp, 200);
      } ) {
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");

      auto result = uc.remove(id, tenantId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } ) {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json clientToJson(ref Client c) {
    auto jj = Json.emptyObject;
    jj["clientId"] = Json(c.clientId);
    jj["tenantId"] = Json(c.tenantId);
    jj["clientName"] = Json(c.clientName);
    jj["description"] = Json(c.description);
    jj["isActive"] = Json(c.isActive);
    jj["createdAt"] = Json(c.createdAt);
    jj["modifiedAt"] = Json(c.modifiedAt);
    return jj;
  }
}
