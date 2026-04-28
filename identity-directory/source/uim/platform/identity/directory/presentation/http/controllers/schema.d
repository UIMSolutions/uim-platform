/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.schema;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import uim.platform.identity.directory.application.usecases.manage.schemas;
// import uim.platform.identity.directory.application.dto;
// import uim.platform.identity.directory.domain.entities.schema;
// import uim.platform.identity_authentication.presentation.http.json_utils;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// HTTP controller for custom schema management.
class SchemaController : PlatformController {
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto createReq = CreateSchemaRequest(req.headers.get("X-Tenant-Id", ""),
          j.getString("name"), j.getString("description"), parseSchemaAttributes(j),);

      auto result = useCase.createSchema(createReq);
      auto response = Json.emptyObject;

      if (result.isSuccess()) {
        response["id"] = Json(result.schemaId);
        res.writeJsonBody(response, 201);
      }
      else
      {
        writeScimError(res, 409, result.error);
      }
    }
    catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
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

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto schemaId = extractIdFromPath(req.requestURI);
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

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto schemaId = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto updateReq = UpdateSchemaRequest(schemaId, j.getString("name"),
          j.getString("description"), parseSchemaAttributes(j),);
      auto error = useCase.updateSchema(updateReq);
      if (error.length > 0)
        writeScimError(res, 404, error);
      else
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("updated");
        res.writeJsonBody(resp, 200);
      }
    }
    catch (Exception e) {
      writeScimError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto schemaId = extractIdFromPath(req.requestURI);
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
  if (val.isNull || (*val).type != Json.Type.array)
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

  // import std.conv : to;
  errRes["status"] = Json(status.to!string);
  res.writeJsonBody(errRes, status);
}
