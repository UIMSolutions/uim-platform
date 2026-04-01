module presentation.http.replication_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.use_cases.manage_replication_jobs;
import application.dto;
import domain.entities.replication_job;
import domain.types;
import presentation.http.json_utils;

class ReplicationController
{
    private ManageReplicationJobsUseCase uc;

    this(ManageReplicationJobsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/replication-jobs", &handleCreate);
        router.get("/api/v1/replication-jobs", &handleList);
        router.get("/api/v1/replication-jobs/*", &handleGetById);
        router.post("/api/v1/replication-jobs/start/*", &handleStart);
        router.post("/api/v1/replication-jobs/pause/*", &handlePause);
        router.post("/api/v1/replication-jobs/cancel/*", &handleCancel);
        router.delete_("/api/v1/replication-jobs/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateReplicationJobRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.distributionModelId = j.getString("distributionModelId");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.trigger = j.getString("trigger");
            r.categories = jsonStrArray(j, "categories");
            r.sourceClientId = j.getString("sourceClientId");
            r.targetClientIds = jsonStrArray(j, "targetClientIds");
            r.isInitialLoad = j.getBoolean("isInitialLoad");
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
            auto modelId = req.params.get("distributionModelId", "");

            ReplicationJob[] jobs;
            if (status.length > 0)
                jobs = uc.listByStatus(tenantId, status);
            else if (modelId.length > 0)
                jobs = uc.listByDistributionModel(tenantId, modelId);
            else
                jobs = uc.listByTenant(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref j; jobs)
                arr ~= serializeJob(j);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) jobs.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto job = uc.getJob(id);
            if (job.id.length == 0)
            {
                writeError(res, 404, "Replication job not found");
                return;
            }
            res.writeJsonBody(serializeJob(job), 200);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleStart(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.startJob(id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 200);
            else
                writeError(res, 400, result.error);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handlePause(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.pauseJob(id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 200);
            else
                writeError(res, 400, result.error);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.cancelJob(id);
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
            auto result = uc.deleteJob(id);
            if (result.success)
                res.writeBody("", 204);
            else
                writeError(res, 404, result.error);
        }
        catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private Json serializeJob(ref ReplicationJob j)
    {
        auto o = Json.emptyObject;
        o["id"] = Json(j.id);
        o["tenantId"] = Json(j.tenantId);
        o["distributionModelId"] = Json(j.distributionModelId);
        o["name"] = Json(j.name);
        o["description"] = Json(j.description);
        o["status"] = Json(j.status.to!string);
        o["trigger"] = Json(j.trigger.to!string);

        auto catsArr = Json.emptyArray;
        foreach (ref cat; j.categories)
            catsArr ~= Json(cat.to!string);
        o["categories"] = catsArr;

        o["sourceClientId"] = Json(j.sourceClientId);
        o["targetClientIds"] = serializeStrArray(j.targetClientIds);
        o["totalRecords"] = Json(j.totalRecords);
        o["processedRecords"] = Json(j.processedRecords);
        o["successRecords"] = Json(j.successRecords);
        o["errorRecords"] = Json(j.errorRecords);
        o["skippedRecords"] = Json(j.skippedRecords);
        o["errorMessages"] = serializeStrArray(j.errorMessages);
        o["lastDeltaToken"] = Json(j.lastDeltaToken);
        o["isInitialLoad"] = Json(j.isInitialLoad);
        o["startedAt"] = Json(j.startedAt);
        o["completedAt"] = Json(j.completedAt);
        o["createdAt"] = Json(j.createdAt);
        o["createdBy"] = Json(j.createdBy);
        return o;
    }
}
