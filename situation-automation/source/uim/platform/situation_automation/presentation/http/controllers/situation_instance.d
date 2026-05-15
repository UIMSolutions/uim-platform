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

class SituationInstanceController : PlatformController {
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

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreateSituationInstanceRequest r;
            r.tenantId = tenantId;
            r.situationTemplateId = SituationTemplateId(j.getString("situationTemplateId"));
            r.situationInstanceId = SituationInstanceId(j.getString("id"));
            r.description = j.getString("description");
            r.severity = j.getString("severity").to!SituationSeverity;
            r.entityId = j.getString("entityId");
            r.entityTypeId = EntityTypeId(j.getString("entityTypeId"));
            r.contextData = jsonKeyValuePairs(j, "contextData");
            r.assignedTo = j.getString("assignedTo");
            r.sourceSystem = j.getString("sourceSystem");
            r.sourceInstanceId = j.getString("sourceInstanceId");
            r.dueAt = jsonLong(j, "dueAt");

            auto result = usecase.createSituationInstance(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Situation instance created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
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

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = SituationInstanceId(extractIdFromPath(req.requestURI.to!string));

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

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = SituationInstanceId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;

            UpdateSituationInstanceRequest r;
            r.tenantId = tenantId;
            r.situationInstanceId = id;
            r.status = j.getString("status");
            r.severity = j.getString("severity").to!SituationSeverity;
            r.assignedTo = j.getString("assignedTo");

            auto result = usecase.updateSituationInstance(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Situation instance updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleResolve(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.string : lastIndexOf;
            auto tenantId = req.getTenantId;

            auto path = req.requestURI.to!string;
            auto resolveIdx = lastIndexOf(path, "/resolve");
            if (resolveIdx < 0) {
                writeError(res, 400, "Invalid resolve path");
                return;
            }
            auto sub = path[0 .. resolveIdx];
            auto id = SituationInstanceId(extractIdFromPath(sub));

            auto j = req.json;
            ResolveSituationRequest r;
            r.tenantId = tenantId;
            r.situationInstanceId = id;
            r.resolutionType = j.getString("resolutionType");
            r.resolvedBy = j.getString("resolvedBy");
            r.actionId = j.getString("actionId");
            r.ruleId = j.getString("ruleId");
            r.outcome = j.getString("outcome");

            auto result = usecase.resolveSituationInstance(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Situation resolved");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto id = SituationInstanceId(extractIdFromPath(req.requestURI.to!string));
            
            auto result = usecase.deleteSituationInstance(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Situation instance deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
