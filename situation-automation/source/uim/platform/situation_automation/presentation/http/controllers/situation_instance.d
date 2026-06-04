/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.situation_instance;
// import uim.platform.situation_automation.application.usecases.manage.situation_instances;
// import uim.platform.situation_automation.application.dto;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

class SituationInstanceController : ManageHttpController {
    private ManageSituationInstancesUseCase usecase;

    this(ManageSituationInstancesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/situation-automation/instances", &handleList);
        router.get("/api/v1/situation-automation/instances/*", &handleGet);
        router.post("/api/v1/situation-automation/instances", &handleCreate);
        router.put("/api/v1/situation-automation/instances/*", &handleUpdate);
        router.post("/api/v1/situation-automation/instances/*/resolve", &handleResolve);
        router.delete_("/api/v1/situation-automation/instances/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            CreateSituationInstanceRequest r;
            r.tenantId = tenantId;
            r.situationTemplateId = SituationTemplateId(data.getString("situationTemplateId"));
            r.situationInstanceId = SituationInstanceId(precheck.id);
            r.description = data.getString("description");
            r.severity = data.getString("severity").to!SituationSeverity;
            r.entityId = data.getString("entityId");
            r.entityTypeId = EntityTypeId(data.getString("entityTypeId"));
            r.contextData = jsonKeyValuePairs(j, "contextData");
            r.assignedTo = data.getString("assignedTo");
            r.sourceSystem = data.getString("sourceSystem");
            r.sourceInstanceId = data.getString("sourceInstanceId");
            r.dueAt = data.getLong("dueAt");

            auto result = usecase.createSituationInstance(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Situation instance created");

                res.writeJsonBody(resp, 201);
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

            auto instances = usecase.listSituationInstances(tenantId);

            auto jarr = Json.emptyArray;
            foreach (i; instances) {
                jarr ~= Json.emptyObject
                    .set("id", i.id)
                    .set("situationTemplateId", i.situationTemplateId)
                    .set("description", i.description)
                    .set("status", i.status.to!string)
                    .set("severity", i.severity.to!string)
                    .set("entityId", i.entityId)
                    .set("assignedTo", i.assignedTo)
                    .set("detectedAt", i.detectedAt)
                    .set("dueAt", i.dueAt)
                    .set("updatedAt", i.updatedAt);
            }

            auto resp = Json.emptyObject
                .set("count", instances.length)
                .set("resources", jarr)
                .set("message", "Situation instances retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = SituationInstanceId(precheck.id);

            auto i = usecase.getSituationInstance(tenantId, id);
            if (i.isNull) {
                writeError(res, 404, "Situation instance not found");
                return;
            }

            auto resInfo = Json.emptyObject
                .set("type", i.resolution.type.to!string)
                .set("resolvedBy", i.resolution.resolvedBy)
                .set("actionId", i.resolution.actionId)
                .set("ruleId", i.resolution.ruleId)
                .set("outcome", i.resolution.outcome)
                .set("resolvedAt", i.resolution.resolvedAt);

            auto resp = Json.emptyObject
                .set("id", i.id)
                .set("situationTemplateId", i.situationTemplateId)
                .set("description", i.description)
                .set("status", i.status.to!string)
                .set("severity", i.severity.to!string)
                .set("entityId", i.entityId)
                .set("entityTypeId", i.entityTypeId)
                .set("assignedTo", i.assignedTo)
                .set("sourceSystem", i.sourceSystem)
                .set("sourceInstanceId", i.sourceInstanceId)
                .set("retryCount", i.retryCount)
                .set("detectedAt", i.detectedAt)
                .set("dueAt", i.dueAt)
                .set("updatedAt", i.updatedAt)
                .set("resolution", resInfo);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = SituationInstanceId(precheck.id);
            auto data = precheck.data;
            UpdateSituationInstanceRequest r;
            r.tenantId = tenantId;
            r.situationInstanceId = id;
            r.status = data.getString("status");
            r.severity = data.getString("severity").to!SituationSeverity;
            r.assignedTo = data.getString("assignedTo");

            auto result = usecase.updateSituationInstance(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Situation instance updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleResolve(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.string : lastIndexOf;
            auto tenantId = precheck.tenantId;

            auto path = precheck.path;
            auto resolveIdx = lastIndexOf(path, "/resolve");
            if (resolveIdx < 0) {
                writeError(res, 400, "Invalid resolve path");
                return;
            }
            auto sub = path[0 .. resolveIdx];
            auto id = SituationInstanceId(extractIdFromPath(sub));

            auto data = precheck.data;
            ResolveSituationRequest r;
            r.tenantId = tenantId;
            r.situationInstanceId = id;
            r.resolutionType = data.getString("resolutionType");
            r.resolvedBy = data.getString("resolvedBy");
            r.actionId = data.getString("actionId");
            r.ruleId = data.getString("ruleId");
            r.outcome = data.getString("outcome");

            auto result = usecase.resolveSituationInstance(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Situation resolved");

                res.writeJsonBody(resp, 200);
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

            auto id = SituationInstanceId(precheck.id);
            
            auto result = usecase.deleteSituationInstance(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Situation instance deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
