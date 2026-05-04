/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.command;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class CommandController : PlatformController {
    private ManageCommandsUseCase commands;

    this(ManageCommandsUseCase commands) {
        this.commands = commands;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/automation-pilot/commands", &handleList);
        router.get("/api/v1/automation-pilot/commands/*", &handleGet);
        router.post("/api/v1/automation-pilot/commands", &handleCreate);
        router.put("/api/v1/automation-pilot/commands/*", &handleUpdate);
        router.delete_("/api/v1/automation-pilot/commands/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = commands.list();
            auto jarr = items.map!(e => e.toJson()).array;

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
            auto id = CommandId(extractIdFromPath(path));
            auto e = commands.getById(id);
            if (e.id.value.length == 0) {
                writeError(res, 404, "Command not found");
                return;
            }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CommandDTO dto;
            dto.id = CommandId(j.getString("id"));
            dto.tenantId = req.getTenantId;
            dto.catalogId = CatalogId(j.getString("catalogId"));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.version_ = j.getString("version");
            dto.inputSchema = j.getString("inputSchema");
            dto.outputSchema = j.getString("outputSchema");
            dto.steps = j.getString("steps");
            dto.timeout = j.getString("timeout");
            dto.retryCount = j.getString("retryCount");
            dto.tags = j.getString("tags");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = commands.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Command created");

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
            CommandDTO dto;
            dto.commandId = CommandId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.inputSchema = j.getString("inputSchema");
            dto.outputSchema = j.getString("outputSchema");
            dto.steps = j.getString("steps");
            dto.timeout = j.getString("timeout");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = commands.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Command updated");

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
            auto id = CommandId(extractIdFromPath(path));
            auto result = commands.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Command deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
