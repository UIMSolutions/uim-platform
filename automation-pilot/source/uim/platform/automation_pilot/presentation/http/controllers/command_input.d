/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.command_input;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

class CommandInputController : ManageHttpController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) {
            return precheck;
        }

        auto tenantId = precheck.tenantId;

        auto items = commandInputs.listCommandInputs(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        return Json.emptyObject
            .set("count", items.length)
            .set("resources", list)
            .set("message", "Command inputs retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) 
            return precheck;
        

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        CommandInputDTO dto;
        dto.inputId = CommandInputId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.keys = data.getString("keys");
        dto.values = data.getString("values");
        dto.version_ = data.getString("version");
        dto.commandId = data.getString("commandId");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = commandInputs.createCommandInput(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Command Input created");

        return successResponse("Command Input created successfully", "Created", 201, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) 
            return precheck;
        

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = CommandInputId(precheck.id);
        if (id.isNull) 
            return errorResponse("Invalid Command Input ID", 400);

        auto e = commandInputs.getCommandInput(tenantId, id);
        if (e.isNull) 
            return errorResponse("Command Input not found", 404);

        return successResponse("Command Input retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) 
            return precheck;
        

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = CommandInputId(precheck.id);
        if (id.isNull) 
            return errorResponse("Invalid Command Input ID", 400);
        

        auto data = precheck.data;
        CommandInputDTO dto;
        dto.tenantId = tenantId;
        dto.inputId = CommandInputId(precheck.id);
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.keys = data.getString("keys");
        dto.values = data.getString("values");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = commandInputs.updateCommandInput(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);
        return successResponse("Command Input updated successfully", "Updated", 200, Json.emptyObject.set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) 
            return precheck;
        

        auto tenantId = precheck.tenantId;
        auto id = CommandInputId(precheck.id);
        if (id.isNull) {
            return errorResponse("Invalid Command Input ID", 400);
        }

        auto result = commandInputs.deleteCommandInput(tenantId, id);
        if (result.hasError) {
            return errorResponse(result.message, 404);
        }

        return successResponse("Command Input deleted successfully", "Deleted", 200, Json.emptyObject.set("id", result.id));
    }
}
