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
    private ManageTriggersUseCase usecase;

    this(ManageTriggersUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/automation-pilot/triggers", &handleList);
        router.get("/api/v1/automation-pilot/triggers/*", &handleGet);
        router.post("/api/v1/automation-pilot/triggers", &handleCreate);
        router.put("/api/v1/automation-pilot/triggers/*", &handleUpdate);
        router.delete_("/api/v1/automation-pilot/triggers/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = usecase.list(tenantId);
            auto jarr = items.map!(e => e.triggerToJson()).array.toJson;
            
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
                .set("message", "Trigger list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = TriggerId(extractIdFromPath(path));

            auto e = usecase.getTrigger(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Trigger not found"); return; }
            res.writeJsonBody(e.triggerToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto j = req.json;

            TriggerDTO dto;
            dto.id = TriggerId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.commandId = j.getString("commandId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.eventType = j.getString("eventType");
            dto.eventSource = j.getString("eventSource");
            dto.filterExpression = j.getString("filterExpression");
            dto.inputMapping = j.getString("inputMapping");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createTrigger(dto);
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

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;

            TriggerDTO dto;
            dto.tenantId = tenantId;
            dto.id = TriggerId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.eventType = j.getString("eventType");
            dto.eventSource = j.getString("eventSource");
            dto.filterExpression = j.getString("filterExpression");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateTrigger(dto);
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

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto id = TriggerId(extractIdFromPath(path));
            
            auto result = usecase.deleteTrigger(tenantId, id);
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
