/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.provider_controller;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.content_agent.application.usecases.manage.content_providers;
// import uim.platform.content_agent.application.dto;
// import uim.platform.content_agent.domain.entities.content_provider;
// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
class ProviderController : PlatformController {
  private ManageContentProvidersUseCase uc;

  this(ManageContentProvidersUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/providers", &handleRegister);
    router.get("/api/v1/providers", &handleList);
    router.get("/api/v1/providers/*", &handleGetById);
    router.put("/api/v1/providers/*", &handleUpdate);
    router.delete_("/api/v1/providers/*", &handleDeregister);
    router.post("/api/v1/providers/sync", &handleSync);
  }

  private void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = RegisterProviderRequest();
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.endpoint = j.getString("endpoint");
      r.authToken = j.getString("authToken");
      r.registeredBy = req.headers.get("X-User-Id", "");

      auto result = uc.registerProvider(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Provider registered successfully");

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
      auto providers = uc.listProviders(tenantId);

      auto arr = providers.map!(p => p.toJson).array;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(providers.length))
        .set("message", "Providers retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto provider = uc.getProvider(id);
      if (provider.isNull) {
        writeError(res, 404, "Provider not found");
        return;
      }
      res.writeJsonBody(provider.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateProviderRequest();
      r.description = j.getString("description");
      r.endpoint = j.getString("endpoint");
      r.authToken = j.getString("authToken");

      auto result = uc.updateProvider(id, r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Provider updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.error == "Provider not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDeregister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deregisterProvider(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Provider deregistered successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleSync(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto providerId = j.getString("providerId");

      auto result = uc.syncProvider(providerId);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Provider synced successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeProvider(const ContentProvider p) {
    auto j = Json.emptyObject
      .set("id", p.id)
      .set("tenantId", p.tenantId)
      .set("name", p.name)
      .set("description", p.description)
      .set("endpoint", p.endpoint)
      .set("status", p.status.to!string)
      .set("createdBy", p.createdBy)
      .set("registeredAt", p.registeredAt)
      .set("lastSyncAt", p.lastSyncAt);

    if (p.contentTypes.length > 0) {
      auto arr = Json.emptyArray;
      foreach (ct; p.contentTypes) {
        arr ~= Json.emptyObject
          .set("typeId", ct.typeId)
          .set("name", ct.name)
          .set("category", ct.category.to!string)
          .set("description", ct.description)
          .set("version", ct.version_);
      }
      j["contentTypes"] = arr;
    }

    return j;
  }
}
