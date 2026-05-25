/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.presentation.http.controllers.provider;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
class ProviderController : ManageController {
  private ManageProvidersUseCase usecase;

  this(ManageProvidersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/spatial/providers", &handleList);
    router.get("/api/v1/spatial/providers/*", &handleGet);
    router.post("/api/v1/spatial/providers", &handleCreate);
    router.put("/api/v1/spatial/providers/*", &handleUpdate);
    router.delete_("/api/v1/spatial/providers/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateProviderRequest r;
      r.tenantId = tenantId;
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.apiKey = j.getString("apiKey");
      r.baseUrl = j.getString("baseUrl");
      r.supportsGeocoding = j.getBoolean("supportsGeocoding");
      r.supportsRouting = j.getBoolean("supportsRouting");
      r.supportsMapping = j.getBoolean("supportsMapping");
      r.supportsIsoline = j.getBoolean("supportsIsoline");
      r.supportsPoi = j.getBoolean("supportsPoi");
      r.supportedRegions = getStrings(j, "supportedRegions");
      r.config = jsonKeyValuePairs(j, "config");

      auto result = usecase.create(r);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Provider created"), 201);
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
      auto items = usecase.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (item; items) {
        jarr ~= Json.emptyObject
          .set("id", item.id.value)
          .set("name", item.name)
          .set("type", item.type.to!string)
          .set("status", item.status.to!string)
          .set("supportsGeocoding", item.supportsGeocoding)
          .set("supportsRouting", item.supportsRouting)
          .set("createdAt", item.createdAt);
      }

      res.writeJsonBody(Json.emptyObject.set("count", Json(items.length)).set("resources", jarr), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto item = usecase.getById(tenantId, id);
      if (item.isNull) {
        writeError(res, 404, "Provider not found");
        return;
      }
      res.writeJsonBody(item.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdateProviderRequest r;
      r.tenantId = tenantId;
      r.id = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.status = j.getString("status");
      r.apiKey = j.getString("apiKey");
      r.baseUrl = j.getString("baseUrl");
      r.supportsGeocoding = j.getBoolean("supportsGeocoding");
      r.supportsRouting = j.getBoolean("supportsRouting");
      r.supportsMapping = j.getBoolean("supportsMapping");
      r.supportsIsoline = j.getBoolean("supportsIsoline");
      r.supportsPoi = j.getBoolean("supportsPoi");

      auto result = usecase.update(r);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Provider updated"), 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = usecase.remove(tenantId, id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject.set("message", "Deleted"), 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
