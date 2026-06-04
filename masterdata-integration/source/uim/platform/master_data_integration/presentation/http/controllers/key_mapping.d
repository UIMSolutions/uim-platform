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
      r.masterDataObjectId = data.getString("masterDataObjectId");
      r.category = data.getString("category");
      r.objectType = data.getString("objectType");
      r.entries = parseEntries(j);

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
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

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
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

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      UpdateKeyMappingRequest r;
      r.entries = parseEntries(j);

      auto result = usecase.updateMapping(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.deleteMapping(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private KeyMappingEntryDto[] parseEntries(Json j) {
    KeyMappingEntryDto[] entries;
    auto entriesArr = jsonObjArray(j, "entries");
    foreach (ej; entriesArr) {
      KeyMappingEntryDto e;
      e.clientId = edata.getString("clientId");
      e.systemId = edata.getString("systemId");
      e.localKey = edata.getString("localKey");
      e.sourceType = edata.getString("sourceType");
      e.isPrimary = getBoolean(ej, "isPrimary");
      entries ~= e;
    }
    return entries;
  }
}
