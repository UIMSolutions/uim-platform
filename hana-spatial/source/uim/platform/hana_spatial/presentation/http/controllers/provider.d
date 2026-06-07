/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.presentation.http.controllers.provider;

import uim.platform.hana_spatial;

// mixin(ShowModule!());

@safe:
class ProviderController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateProviderRequest r;
    r.tenantId = tenantId;
    r.providerId = ProviderId(precheck.id);
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

    return successResponse("Provider created successfully", 201, Json.emptyObject.set("id", result
        .id));
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

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

    return successResponse("Provider list retrieved successfully", 200, Json.emptyObject
        .set("count", items.length)
        .set("resources", jarr));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto item = usecase.getById(tenantId, id);
    if (item.isNull)
      return errorResponse("", 0);

    return successResponse("Provider retrieved successfully", 200, item.toJson());
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ProviderId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid provider ID", 400);

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

    return successResponse("Provider updated successfully", 200);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto result = usecase.remove(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Provider deleted successfully", 200);
  }
}
