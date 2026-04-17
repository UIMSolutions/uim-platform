/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.provider;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import uim.platform.portal.application.usecases.manage.providers;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.content_provider;
// import uim.platform.portal.domain.types;
// import uim.platform.identity_authentication.presentation.http.json_utils;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class ProviderController : PlatformController {
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto createReq = CreateProviderRequest(req.headers.get("X-Tenant-Id", ""),
        j.getString("name"), j.getString("description"), jsonEnum!ProviderType(j,
          "providerType", ProviderType.local),
        j.getString("contentEndpointUrl"), j.getString("authToken"),);

      auto result = useCase.createProvider(createReq);
      if (result.isSuccess()) {
        auto response = Json.emptyObject
          .set("id", result.providerId);

        res.writeJsonBody(response, 201);
      } else {
        writeApiError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto providers = useCase.listProviders(tenantId);
      auto response = Json.emptyObject
        .set("totalResults", providers.length)
        .set("resources", providers);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto providerId = extractIdFromPath(req.requestURI);
      auto provider = useCase.getProvider(providerId);
      if (provider == ContentProvider.init) {
        writeApiError(res, 404, "Content provider not found");
        return;
      }
      res.writeJsonBody(toJsonValue(provider), 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto providerId = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto updateReq = UpdateProviderRequest(providerId, j.getString("name"),
        j.getString("description"), j.getString("contentEndpointUrl"),
        j.getString("authToken"), j.getBoolean("active", true),);

      auto error = useCase.updateProvider(updateReq);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto providerId = extractIdFromPath(req.requestURI);
      auto error = useCase.deleteProvider(providerId);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }
}
