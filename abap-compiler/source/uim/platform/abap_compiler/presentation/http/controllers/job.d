/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.presentation.http.controllers.job;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// HTTP controller for compilation job query.
/// Endpoints:
///   GET /api/v1/abap/jobs             — list all jobs for tenant
///   GET /api/v1/abap/jobs/*           — get specific job
///   DELETE /api/v1/abap/jobs/*        — delete job record
class JobController : ManageController {
    private ManageJobsUseCase usecase;

    this(ManageJobsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/abap/jobs", &handleList);
        router.get("/api/v1/abap/jobs/*", &handleGet);
        router.delete_("/api/v1/abap/jobs/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto jobs = usecase.listJobs(tenantId);
        auto list = jobs.map!(j => j.toJson).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", jobs.length)
            .set("resources", list);

        return successResponse("Job list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = CompilationJobId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid job ID", 400);

        auto job = usecase.getJob(tenantId, id);
        if (job.isNull)
            return errorResponse("Job not found", 404);

        auto responseData = job.toJson();
        return successResponse("Job retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = CompilationJobId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid job ID", 400);

        auto result = usecase.deleteJob(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Job deleted successfully", "Deleted", 200, responseData);
    }
}
