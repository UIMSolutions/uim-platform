/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.client;
// import uim.platform.document_ai.application.usecases.manage.clients;
// import uim.platform.document_ai.application.dto;
// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.client : Client;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class ClientController : ManageController {
  private ManageClientsUseCase usecase;

  this(ManageClientsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/admin/clients", &handleCreate);
    router.get("/api/v1/admin/clients", &handleList);
    router.get("/api/v1/admin/clients/*", &handleGet);
    router.patch("/api/v1/admin/clients/*", &handlePatch);
    router.delete_("/api/v1/admin/clients/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateClientRequest r;
      r.tenantId = tenantId;
      r.clientName = data.getString("clientName");
      r.description = data.getString("description");

      auto result = usecase.createClient(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("clientId", result.id)
          .set("message", "Client created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

      auto clients = usecase.listClients(tenantId);
      auto jarr = Json.emptyArray;
      foreach (c; clients) {
        jarr ~= clientToJson(c);
      }

      auto resp = Json.emptyObject
        .set("count", Json(clients.length))
        .set("resources", list);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;

      auto c = usecase.getClient(tenantId, id);
      if (c.clientId.isEmpty) {
        writeError(res, 404, "Client not found");
        return;
      }

      res.writeJsonBody(clientToJson(c), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      PatchClientRequest r;
      r.tenantId = tenantId;
      r.clientId = id;
      r.clientName = data.getString("clientName");
      r.description = data.getString("description");

      auto result = usecase.patchClient(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("clientId", result.id)
          .set("message", "Client updated");

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
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;

      auto result = usecase.deleteClient(tenantId, ClientId(id));
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

  private Json clientToJson(Client c) {
    return Json.emptyObject
      .set("clientId", Json(c.clientId))
      .set("tenantId", Json(c.tenantId))
      .set("clientName", Json(c.clientName))
      .set("description", Json(c.description))
      .set("isActive", Json(c.isActive))
      .set("createdAt", Json(c.createdAt))
      .set("updatedAt", Json(c.updatedAt));
  }
}
