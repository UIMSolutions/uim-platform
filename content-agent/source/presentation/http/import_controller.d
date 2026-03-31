module presentation.http.import_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.import_content;
import application.dto;
import domain.entities.import_job;
import domain.types;
import presentation.http.json_utils;

class ImportController
{
    private ImportContentUseCase uc;

    this(ImportContentUseCase uc)
    {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/imports", &handleStartImport);
        router.get("/api/v1/imports", &handleList);
        router.get("/api/v1/imports/*", &handleGetById);
    }

    private void handleStartImport(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = StartImportRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.packageId = jsonStr(j, "packageId");
            r.transportRequestId = jsonStr(j, "transportRequestId");
            r.sourceFilePath = jsonStr(j, "sourceFilePath");
            r.startedBy = req.headers.get("X-User-Id", "");

            auto result = uc.startImport(r);
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
            auto jobs = uc.listImportJobs(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref j; jobs)
                arr ~= serializeImportJob(j);

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
            auto job = uc.getImportJob(id);
            if (job.id.length == 0)
            {
                writeError(res, 404, "Import job not found");
                return;
            }
            res.writeJsonBody(serializeImportJob(job), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeImportJob(ref const ImportJob imp)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(imp.id);
        j["tenantId"] = Json(imp.tenantId);
        j["packageId"] = Json(imp.packageId);
        j["transportRequestId"] = Json(imp.transportRequestId);
        j["status"] = Json(imp.status.to!string);
        j["sourceFilePath"] = Json(imp.sourceFilePath);
        j["importedSizeBytes"] = Json(imp.importedSizeBytes);
        j["createdBy"] = Json(imp.createdBy);
        j["startedAt"] = Json(imp.startedAt);
        j["completedAt"] = Json(imp.completedAt);
        j["errorMessage"] = Json(imp.errorMessage);
        j["deployedItems"] = toJsonArray(imp.deployedItems);
        return j;
    }
}
