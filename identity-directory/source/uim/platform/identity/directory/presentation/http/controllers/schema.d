/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.presentation.http.schema;

// import uim.platform.identity.directory.application.usecases.manage.schemas;
// import uim.platform.identity.directory.application.dto;
// import uim.platform.identity.directory.domain.entities.schema;
import uim.platform.identity.directory;

// mixin(ShowModule!());

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
    auto request = CreateSchemaRequest;
    request.tenantId = tenantId;
    request.name = data.getString("name");
    request.description = data.getString("description");
    request.attributes = parseSchemaAttributes(j);

    auto result = useCase.createSchema(createReq);
    if (result.hasError)
      return errorResponse(result.errorMessage);

    auto response = Json.emptyObject;
    response["id"] = Json(result.schemaId);

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
    res.writeJsonBody(response, 200);
  }
 catch (Exception e) {
    writeScimError(res, 500, "Internal server error");
  }
}

override protected Json getHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto schemaId = precheck.id;
  auto schema = useCase.getSchema(schemaId);
  if (schema == Schema.init) {
    writeScimError(res, 404, "Schema not found");
    return;
  }
  res.writeJsonBody(toJsonValue(schema), 200);
}
 catch (Exception e) {
  writeScimError(res, 500, "Internal server error");
}
}

override protected Json updateHandler(HTTPServerRequest req) {
  auto precheck = super.updateHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto schemaId = precheck.id;
  auto data = precheck.data;
  auto updateReq = UpdateSchemaRequest(schemaId, data.getString("name"),
    data.getString("description"), parseSchemaAttributes(j),);
  auto error = useCase.updateSchema(updateReq);
  if (error.length > 0)
    writeScimError(res, 404, error);
  else {
    auto resp = Json.emptyObject
      .set("status", "updated");

    res.writeJsonBody(resp, 200);
  }
}
 catch (Exception e) {
  writeScimError(res, 500, "Internal server error");
}
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto schemaId = precheck.id;
  auto error = useCase.deleteSchema(schemaId);
  if (error.length > 0)
    writeScimError(res, 404, error);
  else
    res.writeBody("", 204);
}
 catch (Exception e) {
  writeScimError(res, 500, "Internal server error");
}
}
}

private SchemaAttribute[] parseSchemaAttributes(Json j) {
  SchemaAttribute[] result;
  if (!j.isObject)
    return result;
  auto val = "attributes" in j;
  if (val.isNull || (val).type != Json.Type.array.toJson)
    return result;
  foreach (item; *val) {
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
