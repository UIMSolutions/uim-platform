/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.presentation.http.controllers.schedule;

// import uim.platform.job_scheduling.application.usecases.manage.schedules;
// import uim.platform.job_scheduling.application.dto;

import uim.platform.job_scheduling;

// mixin(ShowModule!());

@safe:

class ScheduleController : ManageHttpController {
    private ManageSchedulesUseCase usecase;

    this(ManageSchedulesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        // /api/v1/scheduler/jobs/{jobId}/schedules
        router.post("/api/v1/scheduler/jobs/*/schedules", &handleCreate);
        router.get("/api/v1/scheduler/jobs/*/schedules", &handleList);
        router.put("/api/v1/scheduler/jobs/*/schedules/activate", &handleActivateAll);
        router.get("/api/v1/scheduler/jobs/*/schedules/*", &handleGet);
        router.put("/api/v1/scheduler/jobs/*/schedules/*", &handleUpdate);
        router.delete_("/api/v1/scheduler/jobs/*/schedules/*", &handleDelete);
        // Search across all jobs
        router.get("/api/v1/scheduler/schedules/search", &handleSearch);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto tenantId = precheck.tenantId;

        auto path = precheck.path;
        auto jobId = extractJobIdFromSchedulePath(path);
        auto data = precheck.data;
        CreateScheduleRequest r;
        r.tenantId = tenantId;
        r.jobId = jobId;
        r.description = data.getString("description");
        r.type = data.getString("type");
        r.format = data.getString("format");
        r.active = data.getBoolean("active", true);
        r.cronExpression = data.getString("cron");
        r.humanReadableSchedule = data.getString("humanReadableSchedule");
        r.repeatInterval = getLong(j, "repeatInterval");
        r.repeatAt = getLong(j, "repeatAt");
        r.time = getLong(j, "time");
        r.startTime = getLong(j, "startTime");
        r.endTime = getLong(j, "endTime");

        auto result = usecase.createSchedule(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("jobId", jobId);

        return successResponse("Schedule created successfully", "Created", 201, resp);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto path = precheck.path;
        auto jobId = JobId(extractJobIdFromSchedulePath(path));

        auto schedules = usecase.listSchedules(tenantId, jobId);
        auto jarr = schedules.map!(s => toJson(s)).array.toJson;

        auto resp = Json.emptyObject
            .set("total", schedules.length)
            .set("results", jarr);

        return successResponse("Schedule list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto path = precheck.path;
        auto ids = extractJobAndScheduleIds(path);

        auto s = usecase.getSchedule(tenantId, ScheduleId(ids[1]), JobId(ids[0]));
        if (s.isNull)
            return errorResponse("Schedule not found", 404);

        return successResponse("Schedule retrieved successfully", "Retrieved", 200, toJson(s));
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto ids = extractJobAndScheduleIds(path);
        auto data = precheck.data;
        UpdateScheduleRequest r;
        r.tenantId = tenantId;
        r.jobId = JobId(ids[0]);
        r.scheduleId = ScheduleId(ids[1]);
        r.description = data.getString("description");
        r.active = data.getBoolean("active", true);
        r.cronExpression = data.getString("cron");
        r.humanReadableSchedule = data.getString("humanReadableSchedule");
        r.repeatInterval = getLong(j, "repeatInterval");
        r.repeatAt = getLong(j, "repeatAt");
        r.time = getLong(j, "time");
        r.startTime = getLong(j, "startTime");
        r.endTime = getLong(j, "endTime");

        auto result = usecase.updateSchedule(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Schedule updated successfully", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto ids = extractJobAndScheduleIds(path);

        auto result = usecase.deleteSchedule(tenantId, ScheduleId(ids[1]), JobId(ids[0]));
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Schedule deleted successfully", 200, responseData);
    }

    protected Json activateAllHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto jobId = JobId(extractJobIdFromSchedulePath(path));
        auto data = precheck.data;
        ActivateAllSchedulesRequest r;
        r.tenantId = tenantId;
        r.jobId = jobId;
        r.active = data.getBoolean("active", true);

        auto result = usecase.activateAllSchedules(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("message", r.active
                    ? "All schedules activated" : "All schedules deactivated");

        return successResponse("All schedules updated successfully", "Updated", 200, resp);
    }

    protected void handleActivateAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = activateAllHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto query = req.params.get("q", "");

            auto schedules = usecase.searchSchedules(query, tenantId, query);

            auto jarr = schedules.map!(s => toJson(s)).array.toJson;

            auto resp = Json.emptyObject
                .set("total", schedules.length)
                .set("results", jarr)
                .set("message", "Search completed");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    // Extract jobId from path: /api/v1/scheduler/jobs/{jobId}/schedules
    private static string extractJobIdFromSchedulePath(string path) {
        import std.string : split;

        auto parts = path.split("/");
        // parts: ["", "api", "v1", "scheduler", "jobs", "{jobId}", "schedules", ...]
        foreach (i, p; parts) {
            if (p == "jobs" && i + 1 < parts.length)
                return parts[i + 1];
        }
        return "";
    }

    // Extract [jobId, scheduleId] from path: /api/v1/scheduler/jobs/{jobId}/schedules/{scheduleId}
    private static string[2] extractJobAndScheduleIds(string path) {
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
