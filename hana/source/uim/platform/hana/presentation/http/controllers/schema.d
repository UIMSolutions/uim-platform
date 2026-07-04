/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.schema;
// import uim.platform.hana.application.usecases.manage.schemas;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class SchemaController : ManageHttpController {
  private ManageSchemasUseCase usecase;

  this(ManageSchemasUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/schemas", &handleList);
    router.get("/api/v1/hana/schemas/*", &handleGet);
    router.post("/api/v1/hana/schemas", &handleCreate);
    router.put("/api/v1/hana/schemas/*", &handleUpdate);
    router.delete_("/api/v1/hana/schemas/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateSchemaRequest r;
    r.tenantId = tenantId;
    r.instanceId = data.getString("instanceId");
    r.id = precheck.id;
    r.name = data.getString("name");
    r.owner = data.getString("owner");
    r.type = data.getString("type");

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Schema created successfully", "Created", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto schemas = usecase.list(tenantId);

    auto jarr = Json.emptyArray;
    foreach (s; schemas) {
      jarr ~= Json.emptyObject
        .set("id", s.id)
        .set("instanceId", s.instanceId)
        .set("name", s.name)
        .set("owner", s.owner)
        .set("tableCount", s.tableCount)
        .set("viewCount", s.viewCount)
        .set("sizeBytes", s.sizeBytes)
        .set("createdAt", s.createdAt);
    }

    auto resp = Json.emptyObject
      .set("count", schemas.length)
      .set("resources", list);

    res.writeJsonBody(resp, 200);
  }
 catch (Exception e) {
    writeError(res, 500, "Internal server error");
  }
}

override protected Json getHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = precheck.id;
  auto s = usecase.getById(tenantId, id);
  if (s.isNull)
    return errorResponse("Schema not found", 404);

  auto resp = Json.emptyObject
    .set("id", s.id)
    .set("instanceId", s.instanceId)
    .set("name", s.name)
    .set("owner", s.owner)
    .set("tableCount", s.tableCount)
    .set("viewCount", s.viewCount)
    .set("procedureCount", s.procedureCount)
    .set("sizeBytes", s.sizeBytes)
    .set("createdAt", s.createdAt)
    .set("updatedAt", s.updatedAt);

  return successResponse("Schema retrieved successfully", "Retrieved", 200, resp);
}

override protected Json updateHandler(HTTPServerRequest req) {
  auto precheck = super.updateHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;

  auto data = precheck.data;
  UpdateSchemaRequest r;
  r.tenantId = tenantId;
  r.id = precheck.id;
  r.owner = data.getString("owner");

  auto result = usecase.update(r);
  if (result.hasError)
    return errorResponse(result.message, 400);
  auto resp = Json.emptyObject
    .set("id", result.id);

  return successResponse("Schema updated successfully", "Updated", 200, resp);
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = SchemaId(precheck.id);
  auto result = usecase.deleteSchema(id);
  if (result.hasError)
    return errorResponse(result.message, 400);
  return successResponse("Schema deleted successfully", "Deleted", 204, Json.emptyObject);
}
}
