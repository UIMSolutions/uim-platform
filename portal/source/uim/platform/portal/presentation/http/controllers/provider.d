/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.provider;

// import uim.platform.portal.application.usecases.manage.providers;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.content_provider;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

// mixin(ShowModule!());

@safe:
class ProviderController : ManageHttpController {
  private ManageProvidersUseCase useCase;

  this(ManageProvidersUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/providers", &handleCreate);
    router.get("/api/v1/providers", &handleList);
    router.get("/api/v1/providers/*", &handleGet);
    router.put("/api/v1/providers/*", &handleUpdate);
    router.delete_("/api/v1/providers/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto createReq = CreateProviderRequest(req.headers.get("X-Tenant-Id", ""),
      data.getString("name"), data.getString("description"), jsonEnum!ProviderType(j,
        "providerType", ProviderType.local),
      data.getString("contentEndpointUrl"), data.getString("authToken"),);

    auto result = useCase.createProvider(createReq);
    if (result.isSuccess()) {
      auto response = Json.emptyObject
        .set("id", result.providerId);

      return successResponse("Content provider created successfully", "Created", 201, response);
    }

    override protected Json listHandler(HTTPServerRequest req) {
      auto precheck = super.listHandler(req);
      if (precheck.hasError)
        return precheck;

      auto tenantId = precheck.tenantId;
      auto providers = useCase.listProviders(tenantId);
      auto response = Json.emptyObject
        .set("totalResults", providers.length)
        .set("resources", providers);

      return successResponse("Content providers retrieved successfully", "OK", 200, response);
    }

    override protected Json getHandler(HTTPServerRequest req) {
      auto precheck = super.getHandler(req);
      if (precheck.hasError)
        return precheck;

      auto tenantId = precheck.tenantId;
      auto providerId = precheck.id;
      auto provider = useCase.getProvider(providerId);
      if (provider.isNull)
        return errorResponse("Content provider not found", 404);

      return successResponse("Content provider retrieved successfully", "OK", 200, provider);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
      auto precheck = super.updateHandler(req);
      if (precheck.hasError)
        return precheck;

      auto tenantId = precheck.tenantId;
      auto providerId = precheck.id;
      auto data = precheck.data;
      auto updateReq = UpdateProviderRequest(providerId, data.getString("name"),
        data.getString("description"), data.getString("contentEndpointUrl"),
        data.getString("authToken"), data.getBoolean("active", true),);

      auto result = useCase.updateProvider(updateReq);
      if (result.hasError)
        return errorResponse(result.message, 404return successResponse(
            "Content provider updated successfully", "OK", 200, Json.emptyObject);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
      auto precheck = super.deleteHandler(req); if (precheck.hasError)
        return precheck; auto tenantId = precheck.tenantId; auto providerId = precheck.id;
          auto result = useCase.deleteProvider(providerId); if (result.hasError) return errorResponse(result.message, 404);

          return successResponse("Content provider deleted successfully", "No Content", 204, Json
              .emptyObject);}
    }
