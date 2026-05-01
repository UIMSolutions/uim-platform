/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.presentation.http.controllers.schedule;

// import uim.platform.job_scheduling.application.usecases.manage.schedules;
// import uim.platform.job_scheduling.application.dto;
// import uim.platform.job_scheduling.presentation.http.json_utils;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

class ScheduleController : PlatformController {
    private ManageSchedulesUseCase uc;

    this(ManageSchedulesUseCase uc) {
        this.uc = uc;
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

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto jobId = extractJobIdFromSchedulePath(path);
            auto j = req.json;

            CreateScheduleRequest r;
            r.tenantId = req.getTenantId;
            r.jobId = jobId;
            r.description = j.getString("description");
            r.type = j.getString("type");
            r.format = j.getString("format");
            r.active = j.getBoolean("active", true);
            r.cronExpression = j.getString("cron");
            r.humanReadableSchedule = j.getString("humanReadableSchedule");
            r.repeatInterval = jsonLong(j, "repeatInterval");
            r.repeatAt = j.getString("repeatAt");
            r.time = j.getString("time");
            r.startTime = jsonLong(j, "startTime");
            r.endTime = jsonLong(j, "endTime");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("jobId", jobId)
                    .set("message", "Schedule created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto jobId = extractJobIdFromSchedulePath(path);
            TenantId tenantId = req.getTenantId;

            auto schedules = uc.list(jobtenantId, id);

            auto jarr = Json.emptyArray;
            foreach (s; schedules) {
                jarr ~= scheduleToJson(s);
            }

            auto resp = Json.emptyObject
                .set("total", schedules.length)
                .set("results", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto ids = extractJobAndScheduleIds(path);
            TenantId tenantId = req.getTenantId;

            auto s = uc.getById(ids[1], ids[0], tenantId);
            if (s.isNull) {
                writeError(res, 404, "Schedule not found");
                return;
            }

            res.writeJsonBody(scheduleToDetailJson(s), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto ids = extractJobAndScheduleIds(path);
            auto j = req.json;

            UpdateScheduleRequest r;
            r.tenantId = req.getTenantId;
            r.jobId = ids[0];
            r.scheduleId = ids[1];
            r.description = j.getString("description");
            r.active = j.getBoolean("active", true);
            r.cronExpression = j.getString("cron");
            r.humanReadableSchedule = j.getString("humanReadableSchedule");
            r.repeatInterval = jsonLong(j, "repeatInterval");
            r.repeatAt = j.getString("repeatAt");
            r.time = j.getString("time");
            r.startTime = jsonLong(j, "startTime");
            r.endTime = jsonLong(j, "endTime");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Schedule updated");
                
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto ids = extractJobAndScheduleIds(path);
            TenantId tenantId = req.getTenantId;

            auto result = uc.remove(ids[1], ids[0], tenantId);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleActivateAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto jobId = extractJobIdFromSchedulePath(path);
            auto j = req.json;

            ActivateAllSchedulesRequest r;
            r.tenantId = req.getTenantId;
            r.jobId = jobId;
            r.active = j.getBoolean("active", true);

            auto result = uc.activateAll(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", r.active 
                        ? "All schedules activated"
                        : "All schedules deactivated");
                
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            TenantId tenantId = req.getTenantId;
            auto query = req.params.get("q", "");

            auto schedules = uc.search(query, tenantId);

            auto jarr = schedules.map!(s => scheduleToJson(s)).array.toJson;

            auto resp = Json.emptyObject
                .set("total", schedules.length)
                .set("results", jarr);

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

    private static Json scheduleToJson(
        ref uim.platform.job_scheduling.domain.entities.schedule.Schedule s) {
        return Json.emptyObject
            .set("scheduleId", s.id)
            .set("jobId", s.jobId)
            .set("description", s.description)
            .set("active", s.active)
            .set("nextRunAt", s.nextRunAt)
            .set("createdAt", s.createdAt);
    }

    private static Json scheduleToDetailJson(
        ref uim.platform.job_scheduling.domain.entities.schedule.Schedule s) {
        return Json.emptyObject
            .set("scheduleId", s.id)
            .set("jobId", s.jobId)
            .set("description", s.description)
            .set("active", s.active)
            .set("cron", s.cronExpression)
            .set("humanReadableSchedule", s.humanReadableSchedule)
            .set("repeatInterval", s.repeatInterval)
            .set("repeatAt", s.repeatAt)
            .set("time", s.time)
            .set("startTime", s.startTime)
            .set("endTime", s.endTime)
            .set("nextRunAt", s.nextRunAt)
            .set("createdAt", s.createdAt)
            .set("updatedAt", s.updatedAt);
    }
}
