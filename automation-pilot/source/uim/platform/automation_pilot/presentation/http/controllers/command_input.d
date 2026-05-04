/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.command_input;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class CommandInputController : PlatformController {
    private ManageCommandInputsUseCase commandInputs;

    this(ManageCommandInputsUseCase commandInputs) {
        this.commandInputs = commandInputs;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/automation-pilot/inputs", &handleList);
        router.get("/api/v1/automation-pilot/inputs/*", &handleGet);
        router.post("/api/v1/automation-pilot/inputs", &handleCreate);
        router.put("/api/v1/automation-pilot/inputs/*", &handleUpdate);
        router.delete_("/api/v1/automation-pilot/inputs/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = commandInputs.list();
            auto jarr = items.map!(e => e.commandInputToJson()).array;

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
            auto id = CommandInputId(extractIdFromPath(path));
            auto e = commandInputs.getById(id);
            if (e.id.value.length == 0) { writeError(res, 404, "Input not found"); return; }
            res.writeJsonBody(e.commandInputToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CommandInputDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.keys = j.getString("keys");
            dto.values = j.getString("values");
            dto.version_ = j.getString("version");
            dto.commandId = j.getString("commandId");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = commandInputs.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Input created");

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
            CommandInputDTO dto;
            dto.commandInputId = CommandInputId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.keys = j.getString("keys");
            dto.values = j.getString("values");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = commandInputs.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Input updated");

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
            auto id = CommandInputId(extractIdFromPath(path));
            auto result = commandInputs.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Input deleted");
                
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
