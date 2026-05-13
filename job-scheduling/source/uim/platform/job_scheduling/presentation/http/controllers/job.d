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
    private ManageJobsUseCase usecase;
    private ManageSchedulesUseCase scheduleUsecase;

    this(ManageJobsUseCase usecase, ManageSchedulesUseCase scheduleUsecase) {
        this.usecase = usecase;
        this.scheduleUsecase = scheduleUsecase;
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

    protected void handleGetCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreateJobRequest r;
            r.tenantId = tenantId;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.actionUrl = j.getString("action");
            r.httpMethod = j.getString("httpMethod");
            r.type = j.getString("type");
            r.active = j.getBoolean("active", true);
            r.startTime = jsonLong(j, "startTime");
            r.endTime = jsonLong(j, "endTime");

            auto result = usecase.createJob(r);
            if (!result.success) {
                writeError(res, 400, result.error);
                return;
            }

            foreach (sj; j.getArray("schedules")) {
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

                scheduleUsecase.createSchedule(sr);
            }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Job created");

            res.writeJsonBody(resp, 201);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto jobs = usecase.listJobs(tenantId);

            auto jarr = jobs.map!(job => job.toJson).array.toJson;
            auto resp = Json.emptyObject
                .set("total", jobs.length)
                .set("results", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = JobId(extractIdFromPath(req.requestURI.to!string));

            auto job = usecase.getById(tenantId, id);
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

    protected void handleGetUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto jobId = JobId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;

            UpdateJobRequest r;
            r.tenantId = tenantId;
            r.jobId = jobId;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.actionUrl = j.getString("action");
            r.httpMethod = j.getString("httpMethod");
            r.active = j.getBoolean("active", true);
            r.startTime = jsonLong(j, "startTime");
            r.endTime = jsonLong(j, "endTime");

            auto result = usecase.updateJob(r);
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

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto jobId = JobId(extractIdFromPath(req.requestURI.to!string));

            // Delete all schedules first
            scheduleUsecase.removeAllByJob(tenantId, jobId);
            auto result = usecase.delete(tenantId, jobId);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetCount(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto resp = Json.emptyObject
                .set("total", usecase.count(tenantId))
                .set("active", usecase.countActive(tenantId))
                .set("inactive", usecase.countInactive(tenantId));

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto query = req.params.get("q", "");

            auto jobs = usecase.searchJobs(query, tenantId);
            auto jarr = jobs.map!(job => job.toJson).array.toJson;

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
