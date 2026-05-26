/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.external_content_provider;


// 
// import uim.platform.workzone.application.usecases.manage.manage.external_content_providers;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.external_content_provider;
// import uim.platform.identity.authentication.presentation.http;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ExternalContentProviderController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = CreateExternalContentProviderRequest();
      r.tenantId = tenantId;
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
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto tenantId = req.getTenantId;
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

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto j = req.json;
      auto r = UpdateExternalContentProviderRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.endpointUrl = j.getString("endpointUrl");

      auto result = useCase.updateProvider(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "External content provider updated successfully");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto tenantId = req.getTenantId;
      auto result = useCase.deleteProvider(tenantId, id);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
