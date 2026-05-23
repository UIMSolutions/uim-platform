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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error);
        }

        auto tenantId = getTenantId(precheck);

        auto items = commandInputs.listCommandInputs(tenantId);
        auto jarr = items.map!(e => e.toJson()).array.toJson;

        return Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr)
            .set("message", "Command inputs retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error);
        }

        auto tenantId = getTenantId(precheck);
        auto j = req.json;

        CommandInputDTO dto;
        dto.commandInputId = CommandInputId(j.getString("id"));
        dto.tenantId = tenantId;
        dto.name = j.getString("name");
        dto.description = j.getString("description");
        dto.keys = j.getString("keys");
        dto.values = j.getString("values");
        dto.version_ = j.getString("version");
        dto.commandId = j.getString("commandId");
        dto.createdBy = UserId(j.getString("createdBy"));

        auto result = commandInputs.createCommandInput(dto);
        if (result.success) {
            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Command Input created");

            return resp.set("status", "success").set("statusCode", 201);
        } else {
            return Json.emptyObject.set("error", result.message).set("status", "error").set("statusCode", 400);
        }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error);
        }

        auto tenantId = getTenantId(precheck);
        auto path = req.requestURI.to!string;
        auto id = CommandInputId(extractIdFromPath(path));
        if (id.isNull) {
            return Json.emptyObject
                .set("error", "Invalid Command Input ID")
                .set("status", "error")
                .set("statusCode", 400);
        }

        auto e = commandInputs.getCommandInput(tenantId, id);
        if (e.isNull) {
            return Json.emptyObject
                .set("error", "Command Input not found")
                .set("status", "error")
                .set("statusCode", 404);
        }

        return e.toJson()
            .set("message", "Command Input retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error);
        }

        auto tenantId = getTenantId(precheck);
        auto path = req.requestURI.to!string;
        auto id = CommandInputId(extractIdFromPath(path));
        if (id.isNull) {
            return Json.emptyObject
                .set("error", "Invalid Command Input ID")
                .set("status", "error")
                .set("statusCode", 400);
        }

        auto data = precheck.data;

        CommandInputDTO dto;
        dto.tenantId = tenantId;
        dto.commandInputId = CommandInputId(extractIdFromPath(path));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.keys = data.getString("keys");
        dto.values = data.getString("values");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = commandInputs.updateCommandInput(dto);
        if (result.hasError) {
            return Json.emptyObject
                .set("error", result.message)
                .set("status", "error")
                .set("statusCode", 400);
        }
        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Command Input updated")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error);
        }

        auto tenantId = getTenantId(precheck);
        auto path = req.requestURI.to!string;
        auto id = CommandInputId(extractIdFromPath(path));
        if (id.isNull) {
            return Json.emptyObject
                .set("error", "Invalid Command Input ID")
                .set("status", "error")
                .set("statusCode", 400);
        }

        auto result = commandInputs.deleteCommandInput(tenantId, id);
        if (result.hasError) {
            return Json.emptyObject
                .set("error", result.message)
                .set("status", "error")
                .set("statusCode", 404);
        }

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Command Input deleted")
            .set("status", "success")
            .set("statusCode", 200);
    }
}
