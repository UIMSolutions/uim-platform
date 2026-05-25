/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.presentation.http.controllers.mta;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

/// REST /api/v1/slm/mtas — deploy, list, get, update, delete deployed MTA solutions.
class MtaController : ManageController {
    private ManageMtasUseCase usecase;

    this(ManageMtasUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/slm/mtas",         &handleList);
        router.get("/api/v1/slm/mtas/*",        &handleGet);
        router.post("/api/v1/slm/mtas",        &handleDeploy);
        router.put("/api/v1/slm/mtas/*",        &handleUpdate);
        router.delete_("/api/v1/slm/mtas/*",    &handleDelete);
    }

    protected void handleDeploy(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            DeployMtaRequest r;
            r.tenantId            = req.getTenantId;
            r.archiveId           = j.getString("archiveId");
            r.solutionType        = j.getString("solutionType");
            r.spaceId             = j.getString("spaceId");
            r.extensionDescriptor = j.getString("extensionDescriptor");
            r.deployedBy          = j.getString("deployedBy");
            r.namespace_          = j.getString("namespace");

            auto result = usecase.deployMta(r);
            if (result.success) {
                res.writeJsonBody(
                    Json.emptyObject
                        .set("operationId", result.id)
                        .set("message", "Deploy operation started"),
                    202
                );
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto mtas = usecase.listMtas(tenantId);
            auto arr = Json.emptyArray;
            foreach (m; mtas) arr ~= m.toJson;
            res.writeJsonBody(
                Json.emptyObject.set("count", mtas.length).set("mtas", arr),
                200
            );
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = MtaId(extractIdFromPath(req.requestURI.to!string));
            auto m = usecase.getMta(tenantId, id);
            if (m.isNull) { writeError(res, 404, "MTA not found"); return; }
            res.writeJsonBody(m.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            UpdateMtaRequest r;
            r.tenantId            = req.getTenantId;
            r.mtaId               = extractIdFromPath(req.requestURI.to!string);
            r.archiveId           = j.getString("archiveId");
            r.extensionDescriptor = j.getString("extensionDescriptor");
            r.updatedBy           = j.getString("updatedBy");

            auto result = usecase.updateMta(r);
            if (result.success) {
                res.writeJsonBody(
                    Json.emptyObject
                        .set("operationId", result.id)
                        .set("message", "Update operation started"),
                    202
                );
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            DeleteMtaRequest r;
            r.tenantId  = req.getTenantId;
            r.mtaId     = extractIdFromPath(req.requestURI.to!string);
            r.deletedBy = req.json.getString("deletedBy");

            auto result = usecase.deleteMta(r);
            if (result.success) {
                res.writeJsonBody(
                    Json.emptyObject
                        .set("operationId", result.id)
                        .set("message", "Delete operation started"),
                    202
                );
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
