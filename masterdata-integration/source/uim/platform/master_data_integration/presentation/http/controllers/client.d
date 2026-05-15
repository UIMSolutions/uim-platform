/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.client;

// import uim.platform.master_data_integration.application.usecases.manage.clients;
// import uim.platform.master_data_integration.application.dto;
// import uim.platform.master_data_integration.domain.entities.client;
// import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
class ClientController : PlatformController {
  private ManageClientsUseCase usecase;

  this(ManageClientsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/clients", &handleCreate);
    router.get("/api/v1/clients", &handleList);
    router.get("/api/v1/clients/*", &handleGet);
    router.put("/api/v1/clients/*", &handleUpdate);
    router.delete_("/api/v1/clients/*", &handleDelete);
    router.post("/api/v1/clients/connect/*", &handleConnect);
    router.post("/api/v1/clients/disconnect/*", &handleDisconnect);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateClientRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.clientType = j.getString("clientType");
      r.systemUrl = j.getString("systemUrl");
      r.destinationName = j.getString("destinationName");
      r.communicationArrangement = j.getString("communicationArrangement");
      r.supportedCategories = getStrings(j, "supportedCategories");
      r.supportsInitialLoad = j.getBoolean("supportsInitialLoad");
      r.supportsDeltaReplication = j.getBoolean("supportsDeltaReplication");
      r.supportsKeyMapping = j.getBoolean("supportsKeyMapping");
      r.authType = j.getString("authType");
      r.clientIdRef = j.getString("clientIdRef");
      r.certificateRef = j.getString("certificateRef");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Client created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto status = req.params.get("status", "");
      auto type = req.params.get("type", "");

      Client[] clients;
      if (status.length > 0)
        clients = usecase.listByStatus(tenantId, status);
      else if (type.length > 0)
        clients = usecase.listByType(tenantId, type);
      else
        clients = usecase.listByTenant(tenantId);

      auto arr = clients.map!(c => c.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", clients.length)
        .set("message", "Clients retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto client = usecase.getClient(id);
      if (client.isNull) {
        writeError(res, 404, "Client not found");
        return;
      }
      res.writeJsonBody(client.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateClientRequest r;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.status = j.getString("status");
      r.systemUrl = j.getString("systemUrl");
      r.destinationName = j.getString("destinationName");
      r.communicationArrangement = j.getString("communicationArrangement");
      r.supportedCategories = getStrings(j, "supportedCategories");
      r.authType = j.getString("authType");
      r.clientIdRef = j.getString("clientIdRef");
      r.certificateRef = j.getString("certificateRef");

      auto result = usecase.updateClient(id, r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("message", "Client updated successfully");
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto result = usecase.deleteClient(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("message", "Client deleted successfully");
        res.writeJsonBody(resp, 204);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleConnect(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto result = usecase.connect(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDisconnect(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto result = usecase.disconnect(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeClient(Client c) {
    auto catsArr = c.supportedCategories.map!(cat => Json(cat.to!string)).array.toJson;

    return Json.emptyObject
      .set("id", Json(c.id))
      .set("tenantId", Json(c.tenantId))
      .set("name", Json(c.name))
      .set("description", Json(c.description))
      .set("clientType", Json(c.clientType.to!string))
      .set("status", Json(c.status.to!string))
      .set("systemUrl", Json(c.systemUrl))
      .set("destinationName", Json(c.destinationName))
      .set("communicationArrangement", Json(c.communicationArrangement))
      .set("supportedCategories", catsArr)
      .set("supportsInitialLoad", Json(c.supportsInitialLoad))
      .set("supportsDeltaReplication", Json(c.supportsDeltaReplication))
      .set("supportsKeyMapping", Json(c.supportsKeyMapping))
      .set("authType", Json(c.authType))
      .set("createdBy", Json(c.createdBy))
      .set("createdAt", Json(c.createdAt))
      .set("updatedAt", Json(c.updatedAt))
      .set("lastSyncAt", Json(c.lastSyncAt));
  }
}
