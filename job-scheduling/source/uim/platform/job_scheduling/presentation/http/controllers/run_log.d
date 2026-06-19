/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.presentation.http.controllers.run_log;

// import uim.platform.job_scheduling.application.usecases.manage.run_logs;

import uim.platform.job_scheduling;

// mixin(ShowModule!());

@safe:

class RunLogController : ManageHttpController {
    private ManageRunLogsUseCase usecase;

    this(ManageRunLogsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        // /api/v1/scheduler/jobs/{jobId}/schedules/{scheduleId}/runLogs
        router.get("/api/v1/scheduler/jobs/*/schedules/*/runLogs", &handleListBySchedule);
        // /api/v1/scheduler/jobs/{jobId}/runLogs
        router.get("/api/v1/scheduler/jobs/*/runLogs", &handleListByJob);
        // Update run log status (async callback)
        router.put("/api/v1/scheduler/jobs/*/runLogs/*", &handleUpdateStatus);
    }

    protected Json listByScheduleHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto ids = extractIds(path);

        auto logs = usecase.listRunLogs(tenantId, ScheduleId(ids[1])); // , JobId(ids[0]));
        auto jarr = logs.map!(l => l.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("total", logs.length)
            .set("results", jarr)
            .set("message", "Run log list retrieved successfully");

        return successResponse("Run log list retrieved successfully", "Retrieved", 200, resp);
    }

    protected void handleListBySchedule(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = listByScheduleHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected Json listByJobHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = JobId(extractJobId(path));
        if (id.isEmpty)
            return errorResponse("Invalid job ID in path", 400);

        auto logs = usecase.listRunLogs(tenantId, id);
        auto jarr = logs.map!(l => l.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("total", logs.length)
            .set("results", jarr);

        return successResponse("Run log list retrieved successfully", "Retrieved", 200, resp);
    }

    protected void handleListByJob(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = listByJobHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected Json updateStatusHandler(HTTPServerRequest req) {
        auto precheck = super.putHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto runLogId = RunLogId(precheck.id);

        auto data = precheck.data;
        UpdateRunLogRequest r;
        r.runLogId = runLogId;
        r.tenantId = tenantId;
        r.status = data.getString("status");
        r.statusMessage = data.getString("statusMessage");
        r.httpStatus = data.getInteger("httpStatus");
        r.completedAt = data.getLong("completedAt");
        r.executionDurationMs = data.getLong("executionDurationMs");

        auto result = usecase.updateStatus(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("id", result.id);

        return successResponse("Run log updated successfully", "Updated", 200, resp);
    }

    protected void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = updateStatusHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    // Extract jobId from path: /api/v1/scheduler/jobs/{jobId}/runLogs
    private static string extractJobId(string path) {
        import std.string : split;

        auto parts = path.split("/");
        foreach (i, p; parts) {
            if (p == "jobs" && i + 1 < parts.length)
                return parts[i + 1];
        }
        return "";
    }

    // Extract [jobId, scheduleId] from path
    private static string[2] extractIds(string path) {
        import std.string : split;

        string[2] ids;
        auto parts = path.split("/");
        foreach (i, p; parts) {
            if (p == "jobs" && i + 1 < parts.length)
                ids[0] = parts[i + 1];
            if (p == "schedules" && i + 1 < parts.length)
                ids[1] = parts[i + 1];
        }
        return ids;
    }
}
