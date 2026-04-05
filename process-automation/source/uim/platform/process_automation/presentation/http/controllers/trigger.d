/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.trigger;

import uim.platform.process_automation.application.usecases.manage.triggers;
import uim.platform.process_automation.application.dto;
import uim.platform.process_automation.presentation.http.json_utils;

import uim.platform.process_automation;

class TriggerController : SAPController {
    private ManageTriggersUseCase uc;

    this(ManageTriggersUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/process-automation/triggers", &handleList);
        router.get("/api/v1/process-automation/triggers/*", &handleGet);
        router.post("/api/v1/process-automation/triggers", &handleCreate);
        router.put("/api/v1/process-automation/triggers/*", &handleUpdate);
        router.delete_("/api/v1/process-automation/triggers/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateTriggerRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.processId = jsonStr(j, "processId");
            r.id = jsonStr(j, "id");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.type = jsonStr(j, "type");
            r.cronExpression = jsonStr(j, "cronExpression");
            r.eventType = jsonStr(j, "eventType");
            r.eventSource = jsonStr(j, "eventSource");
            r.filterExpression = jsonStr(j, "filterExpression");
            r.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Trigger created");
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
            auto triggers = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref t; triggers) {
                auto tj = Json.emptyObject;
                tj["id"] = Json(t.id);
                tj["name"] = Json(t.name);
                tj["type"] = Json(t.type.to!string);
                tj["status"] = Json(t.status.to!string);
                tj["processId"] = Json(t.processId);
                tj["eventType"] = Json(t.eventType);
                tj["lastFiredAt"] = Json(t.lastFiredAt);
                tj["fireCount"] = Json(t.fireCount);
                jarr ~= tj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) triggers.length);
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
            auto t = uc.get_(id);
            if (t.id.length == 0) {
                writeError(res, 404, "Trigger not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(t.id);
            resp["name"] = Json(t.name);
            resp["description"] = Json(t.description);
            resp["type"] = Json(t.type.to!string);
            resp["status"] = Json(t.status.to!string);
            resp["processId"] = Json(t.processId);
            resp["eventType"] = Json(t.eventType);
            resp["eventSource"] = Json(t.eventSource);
            resp["filterExpression"] = Json(t.filterExpression);
            resp["createdBy"] = Json(t.createdBy);
            resp["createdAt"] = Json(t.createdAt);
            resp["modifiedAt"] = Json(t.modifiedAt);
            resp["lastFiredAt"] = Json(t.lastFiredAt);
            resp["fireCount"] = Json(t.fireCount);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateTriggerRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.cronExpression = jsonStr(j, "cronExpression");
            r.eventType = jsonStr(j, "eventType");
            r.filterExpression = jsonStr(j, "filterExpression");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Trigger updated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
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
                resp["message"] = Json("Trigger deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
