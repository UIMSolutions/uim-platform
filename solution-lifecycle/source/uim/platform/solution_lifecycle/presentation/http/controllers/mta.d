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
            auto data = precheck.data;
            DeployMtaRequest r;
            r.tenantId            = req.getTenantId;
            r.archiveId           = data.getString("archiveId");
            r.solutionType        = data.getString("solutionType");
            r.spaceId             = data.getString("spaceId");
            r.extensionDescriptor = data.getString("extensionDescriptor");
            r.deployedBy          = data.getString("deployedBy");
            r.namespace_          = data.getString("namespace");

            auto result = usecase.deployMta(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

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

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = MtaId(precheck.id);
            auto m = usecase.getMta(tenantId, id);
            if (m.isNull) { writeError(res, 404, "MTA not found"); return; }
            res.writeJsonBody(m.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            UpdateMtaRequest r;
            r.tenantId            = req.getTenantId;
            r.mtaId               = extractIdFromPath(req.requestURI.to!string);
            r.archiveId           = data.getString("archiveId");
            r.extensionDescriptor = data.getString("extensionDescriptor");
            r.updatedBy           = data.getString("updatedBy");

            auto result = usecase.updateMta(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
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

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            DeleteMtaRequest r;
            r.tenantId  = req.getTenantId;
            r.mtaId     = extractIdFromPath(req.requestURI.to!string);
            r.deletedBy = req.json.getString("deletedBy");

            auto result = usecase.deleteMta(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
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
