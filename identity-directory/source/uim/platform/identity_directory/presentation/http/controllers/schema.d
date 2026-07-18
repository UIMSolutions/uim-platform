/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.presentation.http.controllers.schema;

// import uim.platform.identity_directory.application.usecases.manage.schemas;

// import uim.platform.identity_directory.domain.entities.schema;
import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// HTTP controller for custom schema management.
class SchemaController : ManageHttpController {
  private ManageSchemasUseCase useCase;

  this(ManageSchemasUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/scim/Schemas", &handleCreate);
    router.get("/scim/Schemas", &handleList);
    router.get("/scim/Schemas/*", &handleGet);
    router.put("/scim/Schemas/*", &handleUpdate);
    router.delete_("/scim/Schemas/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto request = CreateSchemaRequest();
    request.tenantId = tenantId;
    request.name = data.getString("name");
    request.description = data.getString("description");
    request.attributes = parseSchemaAttributes(data);

    auto result = useCase.createSchema(request);
    if (result.hasError)
      return errorResponse(result.errorMessage);

    auto response = Json.emptyObject;
    response["id"] = Json(result.schemaId.value);

    return successResponse("Schema created successfully", "Created", 201, response);
    // writeScimError(res, 409, result.message);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto schemas = useCase.listSchemas(tenantId);
    auto response = Json.emptyObject;
    response["totalResults"] = Json(schemas.length);
    response["Resources"] = toJsonArray(schemas);

    return successResponse("Schema list retrieved successfully", "Retrieved", 200, response);
    //  catch (Exception e) {
    //     writeScimError(res, 500, "Internal server error");
    //   }
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto schemaId = SchemaId(precheck.id);
    auto schema = useCase.getSchema(tenantId, schemaId);
    if (schema.isNull)
      return errorResponse("Schema not found", 404);

    auto response = Json.emptyObject;
    response["id"] = Json(schema.id.value);
    response["name"] = Json(schema.name);
    response["description"] = Json(schema.description);
    response["attributes"] = toJsonArray(schema.attributes);
    return successResponse("Schema retrieved successfully", "Retrieved", 200, response);

    // writeScimError(res, 500, "Internal server error");}
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto schemaId = precheck.id;
    auto data = precheck.data;
    auto updateReq = UpdateSchemaRequest(tenantId);
    updateReq.schemaId = schemaId;
    updateReq.name = data.getString("name");
    updateReq.description = data.getString("description");
    updateReq.attributes = parseSchemaAttributes(data);

    auto result = useCase.updateSchema(updateReq);
    if (result.hasError)
      return errorResponse(result.errorMessage);

    auto resp = Json.emptyObject
      .set("status", "updated");
    return successResponse("Schema updated successfully", "Updated", 200, resp);
    //  writeScimError(res, 500, "Internal server error");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SchemaId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid schema ID", 400);

    auto result = useCase.deleteSchema(tenantId, id);
    if (result.hasError)
      return errorResponse(result.errorMessage);

    return successResponse("Schema deleted successfully", "Deleted", 200, Json.emptyObject);

    // if (error.length > 0)
    // writeScimError(res, 404, error);
    // else
    // res.writeBody("", 204);
    // }
    //  catch (Exception e) {
    // writeScimError(res, 500, "Internal server error");
    // }

  }
}

private SchemaAttribute[] parseSchemaAttributes(Json j) {
  SchemaAttribute[] result;
  if (!j.isObject)
    return result;
  // auto val = "attributes" in j;
  // if (val.isNull || (val).type != Json.Type.array.toJson)
  //   return result;
  foreach (item; j.getArray("attributes")) {
    result ~= SchemaAttribute(item.getString("id"), item.getString("name"),
      item.getString("description"),);
  }
  return result;
}

private void writeScimError(scope HTTPServerResponse res, int status, string detail) {
  auto errRes = Json.emptyObject;
  errRes["schemas"] = Json.emptyArray;
  errRes["schemas"] ~= Json("urn:ietf:params:scim:api:messages:2.0:Error");
  errRes["detail"] = Json(detail);

  errRes["status"] = Json(status.to!string);
  res.writeJsonBody(errRes, status);
}
