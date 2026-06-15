/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.controllers.key_mapping;

// import uim.platform.master_data_integration.application.usecases.manage.key_mappings;

// import uim.platform.master_data_integration.domain.entities.key_mapping;

import uim.platform.master_data_integration;

// mixin(ShowModule!());

@safe:
class KeyMappingController : ManageHttpController {
  private ManageKeyMappingsUseCase usecase;

  this(ManageKeyMappingsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/key-mappings", &handleCreate);
    router.get("/api/v1/key-mappings", &handleList);
    router.get("/api/v1/key-mappings/lookup", &handleLookup);
    router.get("/api/v1/key-mappings/*", &handleGet);
    router.put("/api/v1/key-mappings/*", &handleUpdate);
    router.delete_("/api/v1/key-mappings/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateKeyMappingRequest r;
    r.tenantId = tenantId;
    r.objectId = data.getString("masterDataObjectId");
    r.category = data.getString("category");
    r.objectType = data.getString("objectType");
    r.entries = parseEntries(j);

    auto result = usecase.createMapping(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Key mapping created successfully", 201, resp);
}

override protected Json listHandler(HTTPServerRequest req) {
  auto precheck = super.listHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto objectId = req.params.get("objectId", "");
  auto category = req.params.get("category", "");

  KeyMapping[] mappings;
  if (!objectId.isEmpty)
    mappings = usecase.listMappings(tenantId, objectId);
  else if (category.length > 0)
    mappings = usecase.listMappings(tenantId, category);
  else
    mappings = usecase.listMappings(tenantId);

  auto arr = mappings.map!(m => m.toJson).array.toJson;

  auto resp = Json.emptyObject
    .set("items", arr)
    .set("totalCount", mappings.length);

  return successResponse("Key mappings retrieved successfully", 200, resp);
}

protected Json lookupHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;

  LookupKeyRequest r;
  r.tenantId = tenantId;
  r.sourceClientId = req.params.get("sourceClientId", "");
  r.sourceLocalKey = req.params.get("sourceLocalKey", "");
  r.targetClientId = req.params.get("targetClientId", "");

  if (r.sourceClientId.isEmpty || r.sourceLocalKey.length == 0
    || r.targetClientId.isEmpty) {
    return errorResponse("sourceClientId, sourceLocalKey, and targetClientId are required", 400);
  }

  auto targetKey = usecase.lookupKey(r);
  if (targetKey.length == 0) {
    return errorResponse("Key mapping not found", 404);
  }

  auto resp = Json.emptyObject
    .set("targetLocalKey", targetKey)
    .set("sourceClientId", r.sourceClientId)
    .set("sourceLocalKey", r.sourceLocalKey)
    .set("targetClientId", r.targetClientId);

  return successResponse("Key mapping lookup successful", 200, resp);
}

protected void handleLookup(scope HTTPServerRequest req, scope HTTPServerResponse res) {
  try {
    auto response = lookupHandler(req);
    res.writeJsonBody(response, response.code);
  } catch (Exception e) {
    writeError(res, 500, "Internal server error");
  }
}

override protected Json getHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = KeyMappingId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid key mapping ID", 400);

  auto mapping = usecase.getMapping(tenantId, id);
  if (mapping.isNull)
    return errorResponse("Key mapping not found", 404);

  auto response = mapping.toJson();
  return successResponse("Key mapping retrieved successfully", 200, response);
}

override protected Json updateHandler(HTTPServerRequest req) {
  auto precheck = super.updateHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = KeyMappingId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid key mapping ID", 400);

  auto data = precheck.data;
  UpdateKeyMappingRequest r;
  r.tenantId = tenantId;
  r.mappingId = id;
  r.entries = parseEntries(data);

  auto result = usecase.updateMapping(r);
  if (result.hasError)
    return errorResponse(result.message, 400);

  return successResponse("Key mapping updated successfully", 200);
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = KeyMappingId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid key mapping ID", 400);

  auto result = usecase.deleteMapping(tenantId, id);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto resp = Json.emptyObject
    .set("id", result.id);

  return successResponse("Key mapping deleted successfully", 200, resp);
}

private KeyMappingEntryDto[] parseEntries(Json j) {
  KeyMappingEntryDto[] entries;
  auto entriesArr = jsonObjArray(j, "entries");
  foreach (edata; entriesArr) {
    KeyMappingEntryDto e;
    e.clientId = edata.getString("clientId");
    e.systemId = edata.getString("systemId");
    e.localKey = edata.getString("localKey");
    e.sourceType = edata.getString("sourceType");
    e.isPrimary = getBoolean(edata, "isPrimary");
    entries ~= e;
  }
  return entries;
}
}
