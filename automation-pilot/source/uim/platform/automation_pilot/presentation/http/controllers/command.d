/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.command;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class CommandController : ManageHttpController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = commands.listCommands(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Command list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        CommandDTO dto;
        dto.tenantId = tenantId;
        dto.commandId = CommandId(precheck.id);
        dto.catalogId = CatalogId(data.getString("catalogId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.version_ = data.getString("version");
        dto.inputSchema = data.getString("inputSchema");
        dto.outputSchema = data.getString("outputSchema");
        dto.steps = data.getString("steps");
        dto.timeout = data.getString("timeout");
        dto.retryCount = data.getString("retryCount");
        dto.tags = data.getString("tags");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = commands.createCommand(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Command created successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;

        auto id = CommandId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid command ID", 400);

        auto e = commands.getCommand(tenantId, id);
        if (e.isNull)
            return errorResponse("Command not found", 404);

        auto responseData = e.toJson();
        return successResponse("Command retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto data = precheck.data;
        auto id = CommandId(precheck.id);

        CommandDTO dto;
        dto.tenantId = tenantId;
        dto.commandId = CommandId(precheck.id);
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.inputSchema = data.getString("inputSchema");
        dto.outputSchema = data.getString("outputSchema");
        dto.steps = data.getString("steps");
        dto.timeout = data.getString("timeout");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = commands.updateCommand(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Command updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        
        auto id = CommandId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid command ID", 400);

        auto result = commands.deleteCommand(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Command deleted successfully", "Deleted", 200, responseData);
    }
}
