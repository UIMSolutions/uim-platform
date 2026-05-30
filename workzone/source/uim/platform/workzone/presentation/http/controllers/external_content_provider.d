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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateExternalContentProviderRequest();
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.endpointUrl = data.getString("endpointUrl");
      r.authType = data.getString("authType");
      r.authConfig = data.getString("authConfig");
      r.refreshIntervalSec = data.getInteger("refreshIntervalSec");

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

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
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
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
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
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      auto r = UpdateExternalContentProviderRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.endpointUrl = data.getString("endpointUrl");

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

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
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
