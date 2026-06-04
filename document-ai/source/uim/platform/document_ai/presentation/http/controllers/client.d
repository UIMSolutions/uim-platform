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
class ClientController : ManageHttpController {
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
    
    CreateClientRequest r;
    r.tenantId = tenantId;
    r.clientName = data.getString("clientName");
    r.description = data.getString("description");

    auto result = usecase.createClient(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Client created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto clients = usecase.listClients(tenantId);
    auto list = clients.map!(c => c.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Clients retrieved successfully", 0, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ClientId(precheck.id);
    auto tenantId = precheck.tenantId;

    auto c = usecase.getClient(tenantId, id);
    if (c.isNull)
      return errorResponse("Client not found", 404);

    auto responseData = c.toJson();
    return successResponse("Client retrieved successfully", 0, responseData);
  }

  protected Json handlePatch(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ClientId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid client ID", 400);

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
      .set("id", result.id)
      .set("message", "Client updated");

    return successResponse("Client updated successfully", 200, resp);
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = patchHandler(req);
      res.writeJson(response);
    } catch (Exception e) {
      res.writeJson(errorResponse(e.msg, 500));
    }
  }
}