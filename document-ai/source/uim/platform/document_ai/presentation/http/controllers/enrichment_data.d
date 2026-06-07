/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.enrichment_data;
// import uim.platform.document_ai.application.usecases.manage.enrichment_data;
// import uim.platform.document_ai.application.dto;
// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.enrichment_data : EnrichmentData;

import uim.platform.document_ai;

// mixin(ShowModule!());

@safe:

class EnrichmentDataController : ManageHttpController {
  private ManageEnrichmentDataUseCase usecase;

  this(ManageEnrichmentDataUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/enrichment-data", &handleCreate);
    router.get("/api/v1/enrichment-data", &handleList);
    router.get("/api/v1/enrichment-data/*", &handleGet);
    router.put("/api/v1/enrichment-data/*", &handleUpdate);
    router.delete_("/api/v1/enrichment-data/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    
    CreateEnrichmentDataRequest r;
    r.tenantId = tenantId;
    r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
    r.documentTypeId = data.getString("documentTypeId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.subtype = data.getString("subtype");
    r.fields = jsonKeyValuePairs(j, "fields");

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Enrichment data created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));
    auto data = usecase.list(tenantId, clientId);

    auto list = data.map!(ed => ed.toJson()).array.toJson;

    auto resp = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);

    return successResponse("Enrichment data list retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = EnrichmentDataId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid enrichment data ID", 400);

    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

    auto ed = usecase.getById(tenantId, id, clientId);
    if (ed.isNull)
      return errorResponse("Enrichment data not found", 404);

    auto responseData = ed.toJson();
    return successResponse("Enrichment data retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = EnrichmentDataId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid enrichment data ID", 400);

    auto data = precheck.data;
    UpdateEnrichmentDataRequest r;
    r.tenantId = tenantId;
    r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
    r.enrichmentDataId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.fields = jsonKeyValuePairs(j, "fields");

    auto result = usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Enrichment data updated successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = EnrichmentDataId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid enrichment data ID", 400);

    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

    auto result = usecase.deleteEnrichmentData(tenantId, id, clientId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Enrichment data deleted successfully", 200, responseData);
  }
}