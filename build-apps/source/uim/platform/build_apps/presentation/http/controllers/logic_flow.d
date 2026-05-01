/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.logic_flow;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class LogicFlowController : PlatformController {
    private ManageLogicFlowsUseCase uc;

    this(ManageLogicFlowsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/build-apps/logic-flows", &handleList);
        router.get("/api/v1/build-apps/logic-flows/*", &handleGet);
        router.post("/api/v1/build-apps/logic-flows", &handleCreate);
        router.put("/api/v1/build-apps/logic-flows/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/logic-flows/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items) jarr ~= e.logicFlowToJson();
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Logic flows retrieved");

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
            auto e = uc.getById(LogicFlowId(id));
            if (e.id.value.length == 0) { writeError(res, 404, "Logic flow not found"); return; }
            res.writeJsonBody(e.logicFlowToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            LogicFlowDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.applicationId = j.getString("applicationId");
            dto.pageId = j.getString("pageId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.trigger = j.getString("trigger");
            dto.triggerConfig = j.getString("triggerConfig");
            dto.nodes = j.getString("nodes");
            dto.connections = j.getString("connections");
            dto.variables = j.getString("variables");
            dto.errorHandler = j.getString("errorHandler");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Logic flow created");

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
            LogicFlowDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.nodes = j.getString("nodes");
            dto.connections = j.getString("connections");
            dto.updatedBy = j.getString("updatedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Logic flow updated");

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
            auto result = uc.remove(LogicFlowId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Logic flow deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
