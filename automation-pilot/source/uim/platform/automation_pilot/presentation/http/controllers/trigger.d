/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.trigger;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class TriggerController : PlatformController {
    private ManageTriggersUseCase uc;

    this(ManageTriggersUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/automation-pilot/triggers", &handleList);
        router.get("/api/v1/automation-pilot/triggers/*", &handleGet);
        router.post("/api/v1/automation-pilot/triggers", &handleCreate);
        router.put("/api/v1/automation-pilot/triggers/*", &handleUpdate);
        router.delete_("/api/v1/automation-pilot/triggers/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items) jarr ~= e.triggerToJson();
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto e = uc.getById(TriggerId(id));
            if (e.id.value.length == 0) { writeError(res, 404, "Trigger not found"); return; }
            res.writeJsonBody(e.triggerToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            TriggerDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.commandId = j.getString("commandId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.eventType = j.getString("eventType");
            dto.eventSource = j.getString("eventSource");
            dto.filterExpression = j.getString("filterExpression");
            dto.inputMapping = j.getString("inputMapping");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Trigger created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            TriggerDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.eventType = j.getString("eventType");
            dto.eventSource = j.getString("eventSource");
            dto.filterExpression = j.getString("filterExpression");
            dto.updatedBy = j.getString("updatedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Trigger updated");

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
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.remove(TriggerId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Trigger deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
