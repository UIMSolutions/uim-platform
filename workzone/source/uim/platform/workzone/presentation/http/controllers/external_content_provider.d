/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.external_content_provider;

// import vibe.http.server;
// import vibe.http.router;
// // import vibe.data.json;
// import uim.platform.workzone.application.usecases.manage.manage.external_content_providers;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.external_content_provider;
// import uim.platform.identity_authentication.presentation.http;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ExternalContentProviderController : PlatformController {
  private ManageExternalContentProvidersUseCase useCase;

  this(ManageExternalContentProvidersUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/external-providers", &handleCreate);
    router.get("/api/v1/external-providers", &handleList);
    router.get("/api/v1/external-providers/*", &handleGet);
    router.put("/api/v1/external-providers/*", &handleUpdate);
    router.delete_("/api/v1/external-providers/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateExternalContentProviderRequest();
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.endpointUrl = j.getString("endpointUrl");
      r.authType = j.getString("authType");
      r.authConfig = j.getString("authConfig");
      r.refreshIntervalSec = j.getInteger("refreshIntervalSec");

      auto result = useCase.createProvider(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "External content provider created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto providers = useCase.listProviders(tenantId);
      auto arr = providers.map!(p => p.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", providers.length)
        .set("message", "External content providers retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto p = useCase.getProvider(tenantId, id);
      if (p.isNull) {
        writeError(res, 404, "Provider not found");
        return;
      }
      res.writeJsonBody(p.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateExternalContentProviderRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.endpointUrl = j.getString("endpointUrl");

      auto result = useCase.updateProvider(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "External content provider updated successfully");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deleteProvider(tenantId, id);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
