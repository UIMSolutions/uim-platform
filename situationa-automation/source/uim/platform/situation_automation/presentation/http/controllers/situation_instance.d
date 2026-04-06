/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.situation_instance;

// import uim.platform.situation_automation.application.usecases.manage.situation_instances;
// import uim.platform.situation_automation.application.dto;
// import uim.platform.situation_automation.presentation.http.json_utils;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

class SituationInstanceController : SAPController {
    private ManageSituationInstancesUseCase uc;

    this(ManageSituationInstancesUseCase uc) {
        this.uc = uc;
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

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateSituationInstanceRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.templateId = jsonStr(j, "templateId");
            r.id = jsonStr(j, "id");
            r.description = jsonStr(j, "description");
            r.severity = jsonStr(j, "severity");
            r.entityId = jsonStr(j, "entityId");
            r.entityTypeId = jsonStr(j, "entityTypeId");
            r.contextData = jsonKeyValuePairs(j, "contextData");
            r.assignedTo = jsonStr(j, "assignedTo");
            r.sourceSystem = jsonStr(j, "sourceSystem");
            r.sourceInstanceId = jsonStr(j, "sourceInstanceId");
            r.dueAt = jsonLong(j, "dueAt");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Situation instance created");
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto instances = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref i; instances) {
                auto ij = Json.emptyObject;
                ij["id"] = Json(i.id);
                ij["templateId"] = Json(i.templateId);
                ij["description"] = Json(i.description);
                ij["status"] = Json(i.status.to!string);
                ij["severity"] = Json(i.severity.to!string);
                ij["entityId"] = Json(i.entityId);
                ij["assignedTo"] = Json(i.assignedTo);
                ij["detectedAt"] = Json(i.detectedAt);
                ij["dueAt"] = Json(i.dueAt);
                ij["modifiedAt"] = Json(i.modifiedAt);
                jarr ~= ij;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) instances.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto i = uc.get_(id);
            if (i.id.length == 0) {
                writeError(res, 404, "Situation instance not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(i.id);
            resp["templateId"] = Json(i.templateId);
            resp["description"] = Json(i.description);
            resp["status"] = Json(i.status.to!string);
            resp["severity"] = Json(i.severity.to!string);
            resp["entityId"] = Json(i.entityId);
            resp["entityTypeId"] = Json(i.entityTypeId);
            resp["assignedTo"] = Json(i.assignedTo);
            resp["sourceSystem"] = Json(i.sourceSystem);
            resp["sourceInstanceId"] = Json(i.sourceInstanceId);
            resp["retryCount"] = Json(cast(long) i.retryCount);
            resp["detectedAt"] = Json(i.detectedAt);
            resp["dueAt"] = Json(i.dueAt);
            resp["modifiedAt"] = Json(i.modifiedAt);

            auto resInfo = Json.emptyObject;
            resInfo["type"] = Json(i.resolution.type.to!string);
            resInfo["resolvedBy"] = Json(i.resolution.resolvedBy);
            resInfo["actionId"] = Json(i.resolution.actionId);
            resInfo["ruleId"] = Json(i.resolution.ruleId);
            resInfo["outcome"] = Json(i.resolution.outcome);
            resInfo["resolvedAt"] = Json(i.resolution.resolvedAt);
            resp["resolution"] = resInfo;

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateSituationInstanceRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.status = jsonStr(j, "status");
            r.severity = jsonStr(j, "severity");
            r.assignedTo = jsonStr(j, "assignedTo");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Situation instance updated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleResolve(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            import std.string : lastIndexOf;

            auto path = req.requestURI.to!string;
            auto resolveIdx = lastIndexOf(path, "/resolve");
            if (resolveIdx < 0) {
                writeError(res, 400, "Invalid resolve path");
                return;
            }
            auto sub = path[0 .. resolveIdx];
            auto id = extractIdFromPath(sub);

            auto j = req.json;
            ResolveSituationRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = id;
            r.resolutionType = jsonStr(j, "resolutionType");
            r.resolvedBy = jsonStr(j, "resolvedBy");
            r.actionId = jsonStr(j, "actionId");
            r.ruleId = jsonStr(j, "ruleId");
            r.outcome = jsonStr(j, "outcome");

            auto result = uc.resolve(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Situation resolved");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Situation instance deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
