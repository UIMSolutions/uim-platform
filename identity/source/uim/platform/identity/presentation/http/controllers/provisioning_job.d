/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.presentation.http.controllers.provisioning_job;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class ProvisioningJobController : ManageController {
    private ManageProvisioningJobsUseCase usecase;

    this(ManageProvisioningJobsUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/ips/provisioning-jobs", &handleList);
        router.get("/api/v1/ips/provisioning-jobs/*", &handleGet);
        router.post("/api/v1/ips/provisioning-jobs", &handleCreate);
        router.put("/api/v1/ips/provisioning-jobs/*", &handleUpdate);
        router.delete_("/api/v1/ips/provisioning-jobs/*", &handleDelete);
        // Action endpoint: POST /api/v1/ips/provisioning-jobs/:id/start
        router.post("/api/v1/ips/provisioning-jobs/*/start", &handleStart);
        router.post("/api/v1/ips/provisioning-jobs/*/cancel", &handleCancel);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listJobs(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Provisioning jobs retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = ProvisioningJobId(extractIdFromPath(path));
            auto e = usecase.getJob(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Provisioning job not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            ProvisioningJobDTO dto;
            dto.jobId = ProvisioningJobId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.sourceSystem = j.getString("sourceSystem");
            dto.targetSystem = j.getString("targetSystem");
            dto.type_ = j.getString("type");

            auto result = usecase.createJob(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Provisioning job created successfully"), 201);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        // Status updates via start/cancel action endpoints; generic PUT not supported
        writeError(res, 405, "Use /start or /cancel action endpoints to change job status");
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = ProvisioningJobId(extractIdFromPath(path));
            auto result = usecase.deleteJob(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Provisioning job deleted successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleStart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            // path: /api/v1/ips/provisioning-jobs/{id}/start
            auto parts = req.requestURI.to!string.split("/");
            string id = parts.length >= 6 ? parts[$ - 2] : "";
            if (id.length == 0) { writeError(res, 400, "Missing job ID"); return; }
            auto result = usecase.startJob(tenantId, ProvisioningJobId(id));
            if (!result.success) { writeError(res, 400, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Provisioning job started"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto parts = req.requestURI.to!string.split("/");
            string id = parts.length >= 6 ? parts[$ - 2] : "";
            if (id.length == 0) { writeError(res, 400, "Missing job ID"); return; }
            auto result = usecase.cancelJob(tenantId, ProvisioningJobId(id));
            if (!result.success) { writeError(res, 400, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Provisioning job cancelled"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
