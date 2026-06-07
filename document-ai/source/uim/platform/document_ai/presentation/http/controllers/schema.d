/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.schema;
// import uim.platform.document_ai.application.usecases.manage.schemas;
// import uim.platform.document_ai.application.dto;
// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.schema : Schema;

import uim.platform.document_ai;

// mixin(ShowModule!());

@safe:

class SchemaController : ManageHttpController {
  private ManageSchemasUseCase usecase;

  this(ManageSchemasUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/schemas", &handleCreate);
    router.get("/api/v1/schemas", &handleList);
    router.get("/api/v1/schemas/*", &handleGet);
    router.put("/api/v1/schemas/*", &handleUpdate);
    router.delete_("/api/v1/schemas/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    
    CreateSchemaRequest r;
    r.tenantId = tenantId;
    r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
    r.documentTypeId = data.getString("documentTypeId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.headerFields = jsonFieldArray(j, "headerFields");
    r.lineItemFields = jsonFieldArray(j, "lineItemFields");
    r.supportedLanguages = data.getStrings("supportedLanguages");

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Schema created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));
    auto schemas = usecase.list(tenantId, clientId);

    auto list = schemas.map!(s => s.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("count", Json(schemas.length))
      .set("resources", list);

    return successResponse("Schemas retrieved successfully", 0, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SchemaId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid schema ID", 400);

    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

    auto s = usecase.getById(tenantId, id, clientId);
    if (s.isNull)
      return errorResponse("Schema not found", 404);

    auto resp = s.toJson;
    ;
    return successResponse("Schema retrieved successfully", 0, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SchemaId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid schema ID", 400);

    auto data = precheck.data;
    UpdateSchemaRequest r;
    r.tenantId = tenantId;
    r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
    r.schemaId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.status = data.getString("status");

    auto result = usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Schema updated successfully", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SchemaId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid schema ID", 400);

    auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

    auto result = usecase.deleteSchema(tenantId, id, clientId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Schema deleted successfully", 200, Json.emptyObject.set("id", id));
  }
}
