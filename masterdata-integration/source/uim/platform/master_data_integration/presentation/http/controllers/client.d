/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.controllers.client;

// import uim.platform.master_data_integration.application.usecases.manage.clients;

import uim.platform.master_data_integration.application.usecases;


import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
class ClientController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;

    CreateClientRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.clientType = data.getString("clientType");
    r.systemUrl = data.getString("systemUrl");
    r.destinationName = data.getString("destinationName");
    r.communicationArrangement = data.getString("communicationArrangement");
    r.supportedCategories = data.getStrings("supportedCategories");
    r.supportsInitialLoad = data.getBoolean("supportsInitialLoad");
    r.supportsDeltaReplication = data.getBoolean("supportsDeltaReplication");
    r.supportsKeyMapping = data.getBoolean("supportsKeyMapping");
    r.authType = data.getString("authType");
    r.clientIdRef = data.getString("clientIdRef");
    r.certificateRef = data.getString("certificateRef");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createClient(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
      
    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Client created successfully", 201, resp);

  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto status = req.params.get("status", "");
    auto type = req.params.get("type", "");

    Client[] clients;
    if (status.length > 0)
      clients = usecase.listClientsByStatus(tenantId, status);
    else if (type.length > 0)
      clients = usecase.listClientsByType(tenantId, type);
    else
      clients = usecase.listClients(tenantId);

    auto arr = clients.map!(c => c.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", clients.length);

    return successResponse("Clients retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ClientId(precheck.id);
    if (id.isNull)
      return errorResponse("Client not found", 404);

    auto client = usecase.getClient(tenantId, id);
    if (client.isNull)
      return errorResponse("Client not found", 404);

    auto obj = client.toJson;
    return successResponse("Client retrieved successfully", 200, obj);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ClientId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid client ID", 400);

    auto data = precheck.data;
    UpdateClientRequest r;
    r.tenantId = tenantId;
    r.clientId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.status = data.getString("status");
    r.systemUrl = data.getString("systemUrl");
    r.destinationName = data.getString("destinationName");
    r.communicationArrangement = data.getString("communicationArrangement");
    r.supportedCategories = data.getStrings("supportedCategories");
    r.authType = data.getString("authType");
    r.clientIdRef = data.getString("clientIdRef");
    r.certificateRef = data.getString("certificateRef");

    auto result = usecase.updateClient(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Client updated successfully", "Updated", 200, Json
        .emptyObject.set("id", id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ClientId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid client ID", 400);

    auto result = usecase.deleteClient(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Client deleted successfully", "Deleted", 200, Json
        .emptyObject.set("id", id));
  }

  override protected Json connectHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ClientId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid client ID", 400);

    auto result = usecase.connectClient(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Client connected successfully", "Connected", 200, resp);
  }

  mixin(HandleTemplate!("handleConnect", "connectHandler"));

  protected Json disconnectHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ClientId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid client ID", 400);

    auto result = usecase.disconnectClient(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Client disconnected successfully", "Disconnected", 200, resp);
  }

  mixin(HandleTemplate!("handleDisconnect", "disconnectHandler"));

}
