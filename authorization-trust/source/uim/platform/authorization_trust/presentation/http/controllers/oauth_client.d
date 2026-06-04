/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.oauth_client;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class OAuthClientController : ManageHttpController {
  private ManageOAuthClientsUseCase usecase;

  this(ManageOAuthClientsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/oauth/clients", &handleCreate);
    router.get("/api/v1/oauth/clients", &handleList);
    router.get("/api/v1/oauth/clients/*", &handleGet);
    router.put("/api/v1/oauth/clients/*", &handleUpdate);
    router.delete_("/api/v1/oauth/clients/*", &handleDelete);
  }

  // POST /api/v1/oauth/clients
  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateOAuthClientRequest r;
    r.tenantId = tenantId;
    r.clientId = data.getString("clientId");
    r.clientSecret = data.getString("clientSecret");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.clientType = data.getString("clientType");
    r.appId = data.getString("appId");

    foreach (v; data.getArray("grantTypes"))
      r.grantTypes ~= v.get!string;

    foreach (v; data.getArray("scopes"))
      r.scopes ~= v.get!string;

    foreach (v; data.getArray("redirectUris"))
      r.redirectUris ~= v.get!string;

    auto result = usecase.createOAuthClient(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("OAuth client created successfully", "Created", 201, responseData);
  }

  // GET /api/v1/oauth/clients
  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto appId = req.query.get("appId", "");
    auto clients = appId.length > 0
      ? usecase.listClients(tenantId, appId) : usecase.listClients(
        tenantId);
    auto list = clients.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("OAuth client list retrieved successfully", "Retrieved", 200, responseData);
  }

  // GET /api/v1/oauth/clients/{id}
  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = OAuthClientId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid OAuth client ID", 400);

    auto client = usecase.getClient(tenantId, id);
    if (client.isNull)
      return errorResponse("OAuth client not found", 404);

    auto responseData = client.toJson();
    return successResponse("OAuth client retrieved successfully", "Retrieved", 200, responseData);
  }

  // PUT /api/v1/oauth/clients/{id}
  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = OAuthClientId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid OAuth client ID", 400);

    auto data = precheck.data;
    UpdateOAuthClientRequest r;
    r.clientId = id;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");

    auto gtArr = data["grantTypes"];
    if (gtArr.isArray)
      foreach (v; gtArr.byValue)
        r.grantTypes ~= v.get!string;

    auto scArr = data["scopes"];
    if (scArr.isArray)
      foreach (v; scArr.byValue)
        r.scopes ~= v.get!string;

    auto ruArr = data["redirectUris"];
    if (ruArr.isArray)
      foreach (v; ruArr.byValue)
        r.redirectUris ~= v.get!string;

    auto result = usecase.updateClient(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("OAuth client updated successfully", "Updated", 200, responseData);
  }

  // DELETE /api/v1/oauth/clients/{id}
  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = OAuthClientId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid OAuth client ID", 400);

    auto result = usecase.deleteClient(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("OAuth client deleted successfully", "Deleted", 200, responseData);
  }
}
