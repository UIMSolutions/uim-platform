module uim.platform.xyz.presentation.http.distribution;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.xyz.application.usecases.manage_distribution_models;
import uim.platform.xyz.application.dto;
import uim.platform.xyz.domain.entities.distribution_model;
import uim.platform.xyz.domain.types;
import uim.platform.xyz.presentation.http.json_utils;

class DistributionController
{
    private ManageDistributionModelsUseCase uc;

    this(ManageDistributionModelsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/distribution-models", &handleCreate);
        router.get("/api/v1/distribution-models", &handleList);
        router.get("/api/v1/distribution-models/*", &handleGetById);
        router.put("/api/v1/distribution-models/*", &handleUpdate);
        router.delete_("/api/v1/distribution-models/*", &handleDelete);
        router.post("/api/v1/distribution-models/activate/*", &handleActivate);
        router.post("/api/v1/distribution-models/deactivate/*", &handleDeactivate);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateDistributionModelRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.direction = j.getString("direction");
            r.sourceClientId = j.getString("sourceClientId");
            r.targetClientIds = jsonStrArray(j, "targetClientIds");
            r.categories = jsonStrArray(j, "categories");
            r.dataModelIds = jsonStrArray(j, "dataModelIds");
            r.filterRuleIds = jsonStrArray(j, "filterRuleIds");
            r.autoReplicate = j.getBoolean("autoReplicate");
            r.cronSchedule = j.getString("cronSchedule");
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
            auto status = req.params.get("status", "");

            DistributionModel[] models;
            if (status.length > 0)
                models = uc.listByStatus(tenantId, status);
            else
                models = uc.listByTenant(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref m; models)
                arr ~= serializeModel(m);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) models.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto model = uc.getModel(id);
            if (model.id.length == 0)
            {
                writeError(res, 404, "Distribution model not found");
                return;
            }
            res.writeJsonBody(serializeModel(model), 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            UpdateDistributionModelRequest r;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.status = j.getString("status");
            r.targetClientIds = jsonStrArray(j, "targetClientIds");
            r.categories = jsonStrArray(j, "categories");
            r.dataModelIds = jsonStrArray(j, "dataModelIds");
            r.filterRuleIds = jsonStrArray(j, "filterRuleIds");
            r.autoReplicate = j.getBoolean("autoReplicate");
            r.cronSchedule = j.getString("cronSchedule");

            auto result = uc.updateModel(id, r);
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
            auto result = uc.deleteModel(id);
            if (result.success)
                res.writeBody("", 204);
            else
                writeError(res, 404, result.error);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.activate(id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 200);
            else
                writeError(res, 400, result.error);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.deactivate(id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 200);
            else
                writeError(res, 400, result.error);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private Json serializeModel(ref DistributionModel m)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(m.id);
        j["tenantId"] = Json(m.tenantId);
        j["name"] = Json(m.name);
        j["description"] = Json(m.description);
        j["status"] = Json(m.status.to!string);
        j["direction"] = Json(m.direction.to!string);
        j["sourceClientId"] = Json(m.sourceClientId);
        j["targetClientIds"] = serializeStrArray(m.targetClientIds);

        auto catsArr = Json.emptyArray;
        foreach (ref cat; m.categories)
            catsArr ~= Json(cat.to!string);
        j["categories"] = catsArr;

        j["dataModelIds"] = serializeStrArray(m.dataModelIds);
        j["filterRuleIds"] = serializeStrArray(m.filterRuleIds);
        j["autoReplicate"] = Json(m.autoReplicate);
        j["cronSchedule"] = Json(m.cronSchedule);
        j["createdBy"] = Json(m.createdBy);
        j["createdAt"] = Json(m.createdAt);
        j["modifiedAt"] = Json(m.modifiedAt);
        return j;
    }
}
