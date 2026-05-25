/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.presentation.http.controllers.job;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

class JobController : ManageController {
    private ManageJobsUseCase jobs;

    this(ManageJobsUseCase jobs) {
        this.jobs = jobs;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/integration-delivery/jobs", &handleList);
        router.get("/api/v1/integration-delivery/jobs/*", &handleGet);
        router.post("/api/v1/integration-delivery/jobs", &handleCreate);
        router.put("/api/v1/integration-delivery/jobs/*", &handleUpdate);
        router.delete_("/api/v1/integration-delivery/jobs/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto items = jobs.listJobs(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Jobs retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto id = JobId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid job ID").set("statusCode", 400);

        auto e = jobs.getJob(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Job not found").set("statusCode", 404);

        return e.toJson().set("message", "Job retrieved successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

        JobDTO dto;
        dto.jobId = JobId(data.getString("jobId", ""));
        dto.tenantId = tenantId;
        dto.name = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.branch = data.getString("branch", "main");
        dto.cronExpression = data.getString("cronExpression", "");
        dto.configurationSource = data.getString("configurationSource", "");
        dto.notifyOnSuccess = data.gBool("notifyOnSuccess");
        dto.notifyOnFailure = data.gBool("notifyOnFailure");
        dto.notificationEmail = data.getString("notificationEmail", "");
        dto.createdBy = UserId(data.getString("createdBy", ""));

        auto result = jobs.createJob(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Job created").set("status", "created").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = JobId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid job ID").set("statusCode", 400);

        JobDTO dto;
        dto.tenantId = tenantId;
        dto.jobId = id;
        dto.name = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.branch = data.getString("branch", "");
        dto.updatedBy = UserId(data.getString("updatedBy", ""));

        auto result = jobs.updateJob(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Job updated").set("status", "updated").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto id = JobId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid job ID").set("statusCode", 400);

        auto result = jobs.deleteJob(tenantId, id);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Job deleted").set("status", "deleted").set("statusCode", 200);
    }
}
