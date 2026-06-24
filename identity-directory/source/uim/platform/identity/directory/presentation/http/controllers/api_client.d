/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.presentation.http.controllers.api_client;

// import uim.platform.identity.directory.application.usecases.manage.api_clients;
// import uim.platform.identity.directory.application.dto;
// import uim.platform.identity.directory.domain.entities.api_client;
import uim.platform.identity.directory;

// mixin(ShowModule!());

@safe:
/// HTTP controller for API client management.
class ApiClientController : ManageHttpController {
  private ManageApiClientsUseCase useCase;

  this(ManageApiClientsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/api-clients", &handleCreate);
    router.get("/api/v1/api-clients", &handleList);
    router.get("/api/v1/api-clients/*", &handleGet);
    router.delete_("/api/v1/api-clients/*", &handleRevoke);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto clients = useCase.listClients(tenantId);

    // Serialize without clientSecret
    auto arr = Json.emptyArray;
    foreach (c; clients) {
      auto j = toJsonValue(c);
      j.remove("clientSecret");
      arr ~= j;
    }

    auto response = Json.emptyObject
      .set("resources", arr)
      .set("totalResults", clients.length);

    return successResponse("API client list retrieved successfully", "Retrieved", 200, response);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateApiClientRequest createReq;
    createReq.tenantId = tenantId;
    createReq.name = data.getString("name");
    createReq.description = data.getString("description");
    createReq.scopes = getStrings(j, "scopes");
    createReq.expiresAt = data.getLong("expiresAt");

    auto result = useCase.createClient(createReq);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("API client created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ApiClientId(precheck.id);
    auto client = useCase.getClient(tenantId, id);
    if (client.isNull)
      return errorResponse("API client not found", 404);

    auto responseData = client.toJson();
    return successResponse("API client retrieved successfully", "Retrieved", 200, responseData);
  }

  protected Json revokeHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ApiClientId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid API client ID", 400);

    auto result = useCase.revokeClient(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("status", "revoked");
    return successResponse("API client revoked successfully", "Revoked", 200, responseData);
  }

  mixin(HandleTemplate!("handleRevoke", "revokeHandler"));

}
