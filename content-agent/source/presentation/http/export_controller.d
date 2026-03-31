module presentation.http.export_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.use_cases.export_content;
import application.dto;
import domain.entities.export_job;
import domain.types;
import presentation.http.json_utils;

class ExportController
{
    private ExportContentUseCase uc;

    this(ExportContentUseCase uc)
    {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/exports", &handleStartExport);
        router.get("/api/v1/exports", &handleList);
        router.get("/api/v1/exports/*", &handleGetById);
    }

    private void handleStartExport(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = StartExportRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.packageId = jsonStr(j, "packageId");
            r.transportRequestId = jsonStr(j, "transportRequestId");
            r.queueId = jsonStr(j, "queueId");
            r.startedBy = req.headers.get("X-User-Id", "");

            auto result = uc.startExport(r);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["status"] = Json("completed");
                res.writeJsonBody(resp, 201);
            }
            else
            {
                writeError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto jobs = uc.listExportJobs(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref j; jobs)
                arr ~= serializeExportJob(j);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) jobs.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto job = uc.getExportJob(id);
            if (job.id.length == 0)
            {
                writeError(res, 404, "Export job not found");
                return;
            }
            res.writeJsonBody(serializeExportJob(job), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeExportJob(ref const ExportJob e)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(e.id);
        j["tenantId"] = Json(e.tenantId);
        j["packageId"] = Json(e.packageId);
        j["transportRequestId"] = Json(e.transportRequestId);
        j["queueId"] = Json(e.queueId);
        j["status"] = Json(e.status.to!string);
        j["exportedFilePath"] = Json(e.exportedFilePath);
        j["exportedSizeBytes"] = Json(e.exportedSizeBytes);
        j["createdBy"] = Json(e.createdBy);
        j["startedAt"] = Json(e.startedAt);
        j["completedAt"] = Json(e.completedAt);
        j["errorMessage"] = Json(e.errorMessage);
        return j;
    }
}
