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
class JobController : PlatformController {
    private ManageJobsUseCase usecase;

    this(ManageJobsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get    ("/api/v1/abap/jobs",  &handleList);
        router.get    ("/api/v1/abap/jobs/*",&handleGet);
        router.delete_("/api/v1/abap/jobs/*",&handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto jobs     = usecase.listJobs(tenantId);
            auto jarr     = Json.emptyArray;
            foreach (j; jobs) jarr ~= j.toJson();
            res.writeJsonBody(Json.emptyObject.set("count", cast(long) jobs.length).set("items", jarr), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id       = extractIdFromPath(req.requestURI.to!string);
            auto job      = usecase.getJob(tenantId, id);
            if (job.isNull) { writeError(res, 404, "Job not found"); return; }
            res.writeJsonBody(job.toJson(), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id       = extractIdFromPath(req.requestURI.to!string);
            auto result   = usecase.deleteJob(tenantId, id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Job deleted"), 200);
            else
                writeError(res, 404, result.errorMessage);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
