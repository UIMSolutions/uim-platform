/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.provider;

// import uim.platform.content_agent.application.usecases.manage.content_providers;

// import uim.platform.content_agent.domain.entities.content_provider;

import uim.platform.content_agent;

// mixin(ShowModule!());

@safe:
class ProviderController : ManageHttpController {
  private ManageContentProvidersUseCase usecase;

  this(ManageContentProvidersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/providers", &handleRegister);
    router.get("/api/v1/providers", &handleList);
    router.get("/api/v1/providers/*", &handleGet);
    router.put("/api/v1/providers/*", &handleUpdate);
    router.delete_("/api/v1/providers/*", &handleDeregister);
    router.post("/api/v1/providers/sync", &handleSync);
  }

  protected Json registerHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = RegisterProviderRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.endpoint = data.getString("endpoint");
    r.authToken = data.getString("authToken");
    r.registeredBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.registerProvider(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Provider registered successfully", 201, responseData);
  }

  protected void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = registerHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto providers = usecase.listProviders(tenantId);
    auto list = providers.map!(p => p.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Providers retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ProviderId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid provider ID", 400);

    auto provider = usecase.getProvider(tenantId, id);
    if (provider.isNull)
      return errorResponse("Provider not found", 404);

    auto responseData = provider.toJson();
    return successResponse("Provider retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ProviderId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid provider ID", 400);

    auto data = precheck.data;
    auto r = UpdateProviderRequest();
    r.tenantId = tenantId;
    r.description = data.getString("description");
    r.endpoint = data.getString("endpoint");
    r.authToken = data.getString("authToken");

    auto result = usecase.updateProvider(id, r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Provider updated successfully", 200, responseData);
  }

  protected Json deregisterHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ProviderId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid provider ID", 400);

    auto result = usecase.deregisterProvider(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Provider deregistered successfully", 200, responseData);
  }

  protected void handleDeregister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = deregisterHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json syncHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto providerId = data.getString("providerId");

    auto result = usecase.syncProvider(providerId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Provider synced successfully", 200, responseData);
  }

  protected void handleSync(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = syncHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
