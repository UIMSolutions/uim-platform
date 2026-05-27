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
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateProviderRequest r;
      r.tenantId = tenantId;
      r.id = precheck.id;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.type = data.getString("type");
      r.apiKey = data.getString("apiKey");
      r.baseUrl = data.getString("baseUrl");
      r.supportsGeocoding = data.getBoolean("supportsGeocoding");
      r.supportsRouting = data.getBoolean("supportsRouting");
      r.supportsMapping = data.getBoolean("supportsMapping");
      r.supportsIsoline = data.getBoolean("supportsIsoline");
      r.supportsPoi = data.getBoolean("supportsPoi");
      r.supportedRegions = data.getStrings("supportedRegions");
      r.config = jsonKeyValuePairs(j, "config");

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
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
      auto tenantId = precheck.tenantId;
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
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
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
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      UpdateProviderRequest r;
      r.tenantId = tenantId;
      r.id = id;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.status = data.getString("status");
      r.apiKey = data.getString("apiKey");
      r.baseUrl = data.getString("baseUrl");
      r.supportsGeocoding = data.getBoolean("supportsGeocoding");
      r.supportsRouting = data.getBoolean("supportsRouting");
      r.supportsMapping = data.getBoolean("supportsMapping");
      r.supportsIsoline = data.getBoolean("supportsIsoline");
      r.supportsPoi = data.getBoolean("supportsPoi");

      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
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
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.remove(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject.set("message", "Deleted"), 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
