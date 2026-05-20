/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.key_mapping;






// import uim.platform.master_data_integration.application.usecases.manage.key_mappings;
// import uim.platform.master_data_integration.application.dto;
// import uim.platform.master_data_integration.domain.entities.key_mapping;
// import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
class KeyMappingController : PlatformController {
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

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateKeyMappingRequest r;
      r.tenantId = tenantId;
      r.masterDataObjectId = j.getString("masterDataObjectId");
      r.category = j.getString("category");
      r.objectType = j.getString("objectType");
      r.entries = parseEntries(j);

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.errorMessage);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto objectId = req.params.get("objectId", "");
      auto category = req.params.get("category", "");

      KeyMapping[] mappings;
      if (!objectId.isEmpty)
        mappings = usecase.listByObjectId(tenantId, objectId);
      else if (category.length > 0)
        mappings = usecase.listByCategory(tenantId, category);
      else
        mappings = usecase.listByTenant(tenantId);

      auto arr = mappings.map!(m => m.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", mappings.length)
        .set("message", "Key mappings retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleLookup(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      LookupKeyRequest r;
      r.tenantId = tenantId;
      r.sourceClientId = req.params.get("sourceClientId", "");
      r.sourceLocalKey = req.params.get("sourceLocalKey", "");
      r.targetClientId = req.params.get("targetClientId", "");

      if (r.sourceClientId.isEmpty || r.sourceLocalKey.length == 0
        || r.targetClientId.isEmpty) {
        writeError(res, 400, "sourceClientId, sourceLocalKey, and targetClientId are required");
        return;
      }

      auto targetKey = usecase.lookupKey(r);
      if (targetKey.length == 0) {
        writeError(res, 404, "Key mapping not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("targetLocalKey", targetKey)
        .set("sourceClientId", r.sourceClientId)
        .set("sourceLocalKey", r.sourceLocalKey)
        .set("targetClientId", r.targetClientId);
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto mapping = usecase.getMapping(id);
      if (mapping.isNull) {
        writeError(res, 404, "Key mapping not found");
        return;
      }
      res.writeJsonBody(mapping.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateKeyMappingRequest r;
      r.entries = parseEntries(j);

      auto result = usecase.updateMapping(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.errorMessage);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto result = usecase.deleteMapping(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.errorMessage);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private KeyMappingEntryDto[] parseEntries(Json j) {
    KeyMappingEntryDto[] entries;
    auto entriesArr = jsonObjArray(j, "entries");
    foreach (ej; entriesArr) {
      KeyMappingEntryDto e;
      e.clientId = ej.getString("clientId");
      e.systemId = ej.getString("systemId");
      e.localKey = ej.getString("localKey");
      e.sourceType = ej.getString("sourceType");
      e.isPrimary = getBoolean(ej, "isPrimary");
      entries ~= e;
    }
    return entries;
  }

  private Json serializeMapping(KeyMapping m) {
    auto entriesArr = Json.emptyArray;
    foreach (e; m.entries) {
      entriesArr ~= Json.emptyObject
        .set("clientId", e.clientId)
        .set("systemId", e.systemId)
        .set("localKey", e.localKey)
        .set("sourceType", e.sourceType.to!string)
        .set("isPrimary", e.isPrimary);
    }

    return Json.emptyObject
      .set("id", m.id)
      .set("tenantId", m.tenantId)
      .set("masterDataObjectId", m.masterDataObjectId)
      .set("category", m.category.to!string)
      .set("objectType", m.objectType)
      .set("entries", entriesArr)
      .set("createdAt", Json(m.createdAt))
      .set("updatedAt", Json(m.updatedAt));
  }
}
