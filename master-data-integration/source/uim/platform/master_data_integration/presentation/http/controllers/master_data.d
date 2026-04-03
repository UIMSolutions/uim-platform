module uim.platform.master_data_integration.presentation.http.master_data;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.master_data_integration.application.usecases.manage_master_data_objects;
import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.master_data_object;
import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.presentation.http.json_utils;

class MasterDataController
{
    private ManageMasterDataObjectsUseCase uc;

    this(ManageMasterDataObjectsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/master-data", &handleCreate);
        router.get("/api/v1/master-data", &handleList);
        router.get("/api/v1/master-data/lookup", &handleLookupByGlobalId);
        router.get("/api/v1/master-data/*", &handleGetById);
        router.put("/api/v1/master-data/*", &handleUpdate);
        router.delete_("/api/v1/master-data/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateMasterDataObjectRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.dataModelId = j.getString("dataModelId");
            r.category = j.getString("category");
            r.objectType = j.getString("objectType");
            r.displayName = j.getString("displayName");
            r.description = j.getString("description");
            r.localId = j.getString("localId");
            r.globalId = j.getString("globalId");
            r.attributes = jsonStrMap(j, "attributes");
            r.sourceSystem = j.getString("sourceSystem");
            r.sourceClient = j.getString("sourceClient");
            r.createdBy = req.headers.get("X-User-Id", "");

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
            auto category = req.params.get("category", "");

            MasterDataObject[] objs;
            if (category.length > 0)
                objs = uc.listByCategory(tenantId, category);
            else
                objs = uc.listByTenant(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref o; objs)
                arr ~= serializeObj(o);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) objs.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleLookupByGlobalId(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto globalId = req.params.get("globalId", "");
            if (globalId.length == 0)
            {
                writeError(res, 400, "globalId query parameter is required");
                return;
            }

            auto obj = uc.findByGlobalId(tenantId, globalId);
            if (obj.id.length == 0)
            {
                writeError(res, 404, "Master data object not found");
                return;
            }
            res.writeJsonBody(serializeObj(obj), 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto obj = uc.getObject(id);
            if (obj.id.length == 0)
            {
                writeError(res, 404, "Master data object not found");
                return;
            }
            res.writeJsonBody(serializeObj(obj), 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            UpdateMasterDataObjectRequest r;
            r.displayName = j.getString("displayName");
            r.description = j.getString("description");
            r.status = j.getString("status");
            r.attributes = jsonStrMap(j, "attributes");
            r.modifiedBy = req.headers.get("X-User-Id", "");

            auto result = uc.updateObject(id, r);
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
            auto result = uc.deleteObject(id);
            if (result.success)
                res.writeBody("", 204);
            else
                writeError(res, 404, result.error);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private Json serializeObj(ref MasterDataObject o)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(o.id);
        j["tenantId"] = Json(o.tenantId);
        j["dataModelId"] = Json(o.dataModelId);
        j["category"] = Json(o.category.to!string);
        j["status"] = Json(o.status.to!string);
        j["objectType"] = Json(o.objectType);
        j["displayName"] = Json(o.displayName);
        j["description"] = Json(o.description);
        j["currentVersion"] = Json(o.currentVersion);
        j["versionNumber"] = Json(o.versionNumber);
        j["localId"] = Json(o.localId);
        j["globalId"] = Json(o.globalId);
        j["attributes"] = serializeStrMap(o.attributes);
        j["sourceSystem"] = Json(o.sourceSystem);
        j["sourceClient"] = Json(o.sourceClient);
        j["createdBy"] = Json(o.createdBy);
        j["createdAt"] = Json(o.createdAt);
        j["modifiedAt"] = Json(o.modifiedAt);
        j["modifiedBy"] = Json(o.modifiedBy);
        return j;
    }
}
