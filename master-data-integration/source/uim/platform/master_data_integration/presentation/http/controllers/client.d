/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.client;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.master_data_integration.application.usecases.manage.clients;
import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.client;
import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.presentation.http.json_utils;

class ClientController : PlatformController {
  private ManageClientsUseCase uc;

  this(ManageClientsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/clients", &handleCreate);
    router.get("/api/v1/clients", &handleList);
    router.get("/api/v1/clients/*", &handleGetById);
    router.put("/api/v1/clients/*", &handleUpdate);
    router.delete_("/api/v1/clients/*", &handleDelete);
    router.post("/api/v1/clients/connect/*", &handleConnect);
    router.post("/api/v1/clients/disconnect/*", &handleDisconnect);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateClientRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.clientType = j.getString("clientType");
      r.systemUrl = j.getString("systemUrl");
      r.destinationName = j.getString("destinationName");
      r.communicationArrangement = j.getString("communicationArrangement");
      r.supportedCategories = jsonStrArray(j, "supportedCategories");
      r.supportsInitialLoad = j.getBoolean("supportsInitialLoad");
      r.supportsDeltaReplication = j.getBoolean("supportsDeltaReplication");
      r.supportsKeyMapping = j.getBoolean("supportsKeyMapping");
      r.authType = j.getString("authType");
      r.clientIdRef = j.getString("clientIdRef");
      r.certificateRef = j.getString("certificateRef");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.create(r);
      if (result.success) {
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
      TenantId tenantId = req.getTenantId;
      auto status = req.params.get("status", "");
      auto type = req.params.get("type", "");

      Client[] clients;
      if (status.length > 0)
        clients = uc.listByStatus(tenantId, status);
      else if (type.length > 0)
        clients = uc.listByType(tenantId, type);
      else
        clients = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref c; clients)
        arr ~= serializeClient(c);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long)clients.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto client = uc.getClient(id);
      if (client.id.isEmpty) {
        writeError(res, 404, "Client not found");
        return;
      }
      res.writeJsonBody(serializeClient(client), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateClientRequest r;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.status = j.getString("status");
      r.systemUrl = j.getString("systemUrl");
      r.destinationName = j.getString("destinationName");
      r.communicationArrangement = j.getString("communicationArrangement");
      r.supportedCategories = jsonStrArray(j, "supportedCategories");
      r.authType = j.getString("authType");
      r.clientIdRef = j.getString("clientIdRef");
      r.certificateRef = j.getString("certificateRef");

      auto result = uc.updateClient(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteClient(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleConnect(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.connect(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDisconnect(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.disconnect(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeClient(ref Client c) {
    auto j = Json.emptyObject;
    j["id"] = Json(c.id);
    j["tenantId"] = Json(c.tenantId);
    j["name"] = Json(c.name);
    j["description"] = Json(c.description);
    j["clientType"] = Json(c.clientType.to!string);
    j["status"] = Json(c.status.to!string);
    j["systemUrl"] = Json(c.systemUrl);
    j["destinationName"] = Json(c.destinationName);
    j["communicationArrangement"] = Json(c.communicationArrangement);

    auto catsArr = Json.emptyArray;
    foreach (ref cat; c.supportedCategories)
      catsArr ~= Json(cat.to!string);
    j["supportedCategories"] = catsArr;

    j["supportsInitialLoad"] = Json(c.supportsInitialLoad);
    j["supportsDeltaReplication"] = Json(c.supportsDeltaReplication);
    j["supportsKeyMapping"] = Json(c.supportsKeyMapping);
    j["authType"] = Json(c.authType);
    j["createdBy"] = Json(c.createdBy);
    j["createdAt"] = Json(c.createdAt);
    j["modifiedAt"] = Json(c.modifiedAt);
    j["lastSyncAt"] = Json(c.lastSyncAt);
    return j;
  }
}
