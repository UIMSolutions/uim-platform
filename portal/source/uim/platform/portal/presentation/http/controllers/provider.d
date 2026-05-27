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

mixin(ShowModule!());

@safe:
class ProviderController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
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

        res.writeJsonBody(response, 201);
      } else {
        writeApiError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto providers = useCase.listProviders(tenantId);
      auto response = Json.emptyObject
        .set("totalResults", providers.length)
        .set("resources", providers);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto providerId = precheck.id;
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

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto providerId = precheck.id;
      auto data = precheck.data;
      auto updateReq = UpdateProviderRequest(providerId, data.getString("name"),
        data.getString("description"), data.getString("contentEndpointUrl"),
        data.getString("authToken"), j.getBoolean("active", true),);

      auto error = useCase.updateProvider(updateReq);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto providerId = precheck.id;
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
