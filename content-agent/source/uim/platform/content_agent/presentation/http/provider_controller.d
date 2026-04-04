/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.provider;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.content_agent.application.usecases.manage.content_providers;
import uim.platform.content_agent.application.dto;
import uim.platform.content_agent.domain.entities.content_provider;
import uim.platform.content_agent.domain.types;
import uim.platform.content_agent.presentation.http.json_utils;

class ProviderController {
  private ManageContentProvidersUseCase uc;

  this(ManageContentProvidersUseCase uc)
  {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/providers", &handleRegister);
    router.get("/api/v1/providers", &handleList);
    router.get("/api/v1/providers/*", &handleGetById);
    router.put("/api/v1/providers/*", &handleUpdate);
    router.delete_("/api/v1/providers/*", &handleDeregister);
    router.post("/api/v1/providers/sync", &handleSync);
  }

  private void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = RegisterProviderRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.endpoint = j.getString("endpoint");
      r.authToken = j.getString("authToken");
      r.registeredBy = req.headers.get("X-User-Id", "");

      auto result = uc.registerProvider(r);
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto providers = uc.listProviders(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref p; providers)
        arr ~= serializeProvider(p);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) providers.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto provider = uc.getProvider(id);
      if (provider.id.length == 0)
      {
        writeError(res, 404, "Provider not found");
        return;
      }
      res.writeJsonBody(serializeProvider(provider), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateProviderRequest();
      r.description = j.getString("description");
      r.endpoint = j.getString("endpoint");
      r.authToken = j.getString("authToken");

      auto result = uc.updateProvider(id, r);
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, result.error == "Provider not found" ? 404 : 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDeregister(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deregisterProvider(id);
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["deregistered"] = Json(true);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleSync(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto providerId = j.getString("providerId");

      auto result = uc.syncProvider(providerId);
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["synced"] = Json(true);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeProvider(ref const ContentProvider p)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(p.id);
    j["tenantId"] = Json(p.tenantId);
    j["name"] = Json(p.name);
    j["description"] = Json(p.description);
    j["endpoint"] = Json(p.endpoint);
    j["status"] = Json(p.status.to!string);
    j["createdBy"] = Json(p.createdBy);
    j["registeredAt"] = Json(p.registeredAt);
    j["lastSyncAt"] = Json(p.lastSyncAt);

    if (p.contentTypes.length > 0)
    {
      auto arr = Json.emptyArray;
      foreach (ref ct; p.contentTypes)
      {
        auto ctj = Json.emptyObject;
        ctj["typeId"] = Json(ct.typeId);
        ctj["name"] = Json(ct.name);
        ctj["category"] = Json(ct.category.to!string);
        ctj["description"] = Json(ct.description);
        ctj["version"] = Json(ct.version_);
        arr ~= ctj;
      }
      j["contentTypes"] = arr;
    }

    return j;
  }
}
