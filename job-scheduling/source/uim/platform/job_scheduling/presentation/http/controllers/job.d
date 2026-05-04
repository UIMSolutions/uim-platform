/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.presentation.http.controllers.job;

// import uim.platform.job_scheduling.application.usecases.manage.jobs;
// import uim.platform.job_scheduling.application.usecases.manage.schedules;
// import uim.platform.job_scheduling.application.dto;

// import uim.platform.job_scheduling;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
class JobController : PlatformController {
    private ManageJobsUseCase jobUc;
    private ManageSchedulesUseCase scheduleUc;

    this(ManageJobsUseCase jobUc, ManageSchedulesUseCase scheduleUc) {
        this.jobUc = jobUc;
        this.scheduleUc = scheduleUc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/scheduler/jobs", &handleCreate);
        router.get("/api/v1/scheduler/jobs", &handleList);
        router.get("/api/v1/scheduler/jobs/count", &handleCount);
        router.get("/api/v1/scheduler/jobs/search", &handleSearch);
        router.get("/api/v1/scheduler/jobs/*", &handleGet);
        router.put("/api/v1/scheduler/jobs/*", &handleUpdate);
        router.delete_("/api/v1/scheduler/jobs/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateJobRequest r;
            r.tenantId = req.getTenantId;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.actionUrl = j.getString("action");
            r.httpMethod = j.getString("httpMethod");
            r.type = j.getString("type");
            r.active = j.getBoolean("active", true);
            r.startTime = jsonLong(j, "startTime");
            r.endTime = jsonLong(j, "endTime");

            auto result = jobUc.create(r);
            if (!result.success) {
                writeError(res, 400, result.error);
                return;
            }

            // Create inline schedules if provided
            auto schedulesJson = "schedules" in j;
            if (schedulesJson !is null && (schedulesJson).isArray) {
                foreach (sj; *schedulesJson) {
                    CreateScheduleRequest sr;
                    sr.tenantId = r.tenantId;
                    sr.jobId = result.id;
                    sr.description = getString(sj, "description");
                    sr.type = getString(sj, "type");
                    sr.format = getString(sj, "format");
                    sr.active = getBoolean(sj, "active", true);
                    sr.cronExpression = getString(sj, "cron");
                    sr.humanReadableSchedule = getString(sj, "humanReadableSchedule");
                    sr.repeatInterval = jsonLong(sj, "repeatInterval");
                    sr.repeatAt = getString(sj, "repeatAt");
                    sr.time = getString(sj, "time");
                    sr.startTime = jsonLong(sj, "startTime");
                    sr.endTime = jsonLong(sj, "endTime");
                    scheduleUc.create(sr);
                }
            }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Job created");

            res.writeJsonBody(resp, 201);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            TenantId tenantId = req.getTenantId;
            auto jobs = jobUc.list(tenantId);

            auto jarr = jobs.map!(job => toJson(job)).array; 

            auto resp = Json.emptyObject
                .set("total", jobs.length)
                .set("results", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            TenantId tenantId = req.getTenantId;

            auto job = jobUc.getById(tenantId, id);
            if (job.isNull) {
                writeError(res, 404, "Job not found");
                return;
            }

            auto resp = jobToDetailJson(job);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;

            UpdateJobRequest r;
            r.tenantId = req.getTenantId;
            r.jobId = id;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.actionUrl = j.getString("action");
            r.httpMethod = j.getString("httpMethod");
            r.active = j.getBoolean("active", true);
            r.startTime = jsonLong(j, "startTime");
            r.endTime = jsonLong(j, "endTime");

            auto result = jobUc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Job updated");

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

            auto id = extractIdFromPath(req.requestURI.to!string);
            TenantId tenantId = req.getTenantId;

            // Delete all schedules first
            scheduleUc.removeAllByJob(tenantId, id);

            auto result = jobUc.removeById(tenantId, id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCount(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            TenantId tenantId = req.getTenantId;

            auto resp = Json.emptyObject
                .set("total", jobUc.count(tenantId))
                .set("active", jobUc.countActive(tenantId))
                .set("inactive", jobUc.countInactive(tenantId));

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            TenantId tenantId = req.getTenantId;
            auto query = req.params.get("q", "");

            auto jobs = jobUc.search(query, tenantId);

            auto jarr = Json.emptyArray;
            foreach (job; jobs) {
                jarr ~= jobToJson(job);
            }

            auto resp = Json.emptyObject
                .set("total", jobs.length)
                .set("results", jarr);
                
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json jobToJson(uim.platform.job_scheduling.domain.entities.job.Job job) {
        return Json.emptyObject
            .set("jobId", job.id)
            .set("name", job.name)
            .set("description", job.description)
            .set("action", job.actionUrl)
            .set("active", job.active)
            .set("createdAt", job.createdAt);
    }

    private static Json jobToDetailJson(uim.platform.job_scheduling.domain.entities.job.Job job) {
        return Json.emptyObject
            .set("jobId", job.id)
            .set("name", job.name)
            .set("description", job.description)
            .set("action", job.actionUrl)
            .set("httpMethod", httpMethodStr(job.httpMethod))
            .set("active", job.active)
            .set("startTime", job.startTime)
            .set("endTime", job.endTime)
            .set("createdAt", job.createdAt)
            .set("updatedAt", job.updatedAt);
    }

    private static string httpMethodStr(uim.platform.job_scheduling.domain.types.HttpMethod m) {
        final switch (m) {
        case uim.platform.job_scheduling.domain.types.HttpMethod.get:
            return "GET";
        case uim.platform.job_scheduling.domain.types.HttpMethod.post:
            return "POST";
        case uim.platform.job_scheduling.domain.types.HttpMethod.put:
            return "PUT";
        case uim.platform.job_scheduling.domain.types.HttpMethod.delete_:
            return "DELETE";
        case uim.platform.job_scheduling.domain.types.HttpMethod.patch:
            return "PATCH";
        }
    }
}
