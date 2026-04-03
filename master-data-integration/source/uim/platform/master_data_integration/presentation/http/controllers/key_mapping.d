module uim.platform.master_data_integration.presentation.http.key_mapping;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.master_data_integration.application.usecases.manage_key_mappings;
import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.key_mapping;
import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.presentation.http.json_utils;

class KeyMappingController
{
    private ManageKeyMappingsUseCase uc;

    this(ManageKeyMappingsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/key-mappings", &handleCreate);
        router.get("/api/v1/key-mappings", &handleList);
        router.get("/api/v1/key-mappings/lookup", &handleLookup);
        router.get("/api/v1/key-mappings/*", &handleGetById);
        router.put("/api/v1/key-mappings/*", &handleUpdate);
        router.delete_("/api/v1/key-mappings/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateKeyMappingRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.masterDataObjectId = j.getString("masterDataObjectId");
            r.category = j.getString("category");
            r.objectType = j.getString("objectType");
            r.entries = parseEntries(j);

            auto result = uc.create(r);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            }
            else
                writeError(res, 400, result.error);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto objectId = req.params.get("objectId", "");
            auto category = req.params.get("category", "");

            KeyMapping[] mappings;
            if (objectId.length > 0)
                mappings = uc.listByObjectId(tenantId, objectId);
            else if (category.length > 0)
                mappings = uc.listByCategory(tenantId, category);
            else
                mappings = uc.listByTenant(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref m; mappings)
                arr ~= serializeMapping(m);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) mappings.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleLookup(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            LookupKeyRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.sourceClientId = req.params.get("sourceClientId", "");
            r.sourceLocalKey = req.params.get("sourceLocalKey", "");
            r.targetClientId = req.params.get("targetClientId", "");

            if (r.sourceClientId.length == 0 || r.sourceLocalKey.length == 0 || r.targetClientId.length == 0)
            {
                writeError(res, 400, "sourceClientId, sourceLocalKey, and targetClientId are required");
                return;
            }

            auto targetKey = uc.lookupKey(r);
            if (targetKey.length == 0)
            {
                writeError(res, 404, "Key mapping not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["targetLocalKey"] = Json(targetKey);
            resp["sourceClientId"] = Json(r.sourceClientId);
            resp["sourceLocalKey"] = Json(r.sourceLocalKey);
            resp["targetClientId"] = Json(r.targetClientId);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto mapping = uc.getMapping(id);
            if (mapping.id.length == 0)
            {
                writeError(res, 404, "Key mapping not found");
                return;
            }
            res.writeJsonBody(serializeMapping(mapping), 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            UpdateKeyMappingRequest r;
            r.entries = parseEntries(j);

            auto result = uc.updateMapping(id, r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 200);
            else
                writeError(res, 400, result.error);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.deleteMapping(id);
            if (result.success)
                res.writeBody("", 204);
            else
                writeError(res, 404, result.error);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private KeyMappingEntryDto[] parseEntries(Json j)
    {
        KeyMappingEntryDto[] entries;
        auto entriesArr = jsonObjArray(j, "entries");
        foreach (ref ej; entriesArr)
        {
            KeyMappingEntryDto e;
            e.clientId = ej.getString( "clientId");
            e.systemId = ej.getString( "systemId");
            e.localKey = ej.getString( "localKey");
            e.sourceType = ej.getString( "sourceType");
            e.isPrimary = jsonBool(ej, "isPrimary");
            entries ~= e;
        }
        return entries;
    }

    private Json serializeMapping(ref KeyMapping m)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(m.id);
        j["tenantId"] = Json(m.tenantId);
        j["masterDataObjectId"] = Json(m.masterDataObjectId);
        j["category"] = Json(m.category.to!string);
        j["objectType"] = Json(m.objectType);

        auto entriesArr = Json.emptyArray;
        foreach (ref e; m.entries)
        {
            auto ej = Json.emptyObject;
            ej["clientId"] = Json(e.clientId);
            ej["systemId"] = Json(e.systemId);
            ej["localKey"] = Json(e.localKey);
            ej["sourceType"] = Json(e.sourceType.to!string);
            ej["isPrimary"] = Json(e.isPrimary);
            entriesArr ~= ej;
        }
        j["entries"] = entriesArr;

        j["createdAt"] = Json(m.createdAt);
        j["modifiedAt"] = Json(m.modifiedAt);
        return j;
    }
}
