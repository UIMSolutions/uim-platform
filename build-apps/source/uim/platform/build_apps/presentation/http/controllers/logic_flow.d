/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.logic_flow;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class LogicFlowController : ManageController {
    private ManageLogicFlowsUseCase usecase;

    this(ManageLogicFlowsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/build-apps/logic-flows", &handleList);
        router.get("/api/v1/build-apps/logic-flows/*", &handleGet);
        router.post("/api/v1/build-apps/logic-flows", &handleCreate);
        router.put("/api/v1/build-apps/logic-flows/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/logic-flows/*", &handleDelete);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();

            auto items = usecase.listLogicFlows(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Logic flows retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto id = LogicFlowId(extractIdFromPath(path));

            auto e = usecase.getLogicFlow(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Logic flow not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto j = req.json;

            LogicFlowDTO dto;
            dto.logicFlowId = LogicFlowId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.applicationId = ApplicationId(j.getString("applicationId"));
            dto.pageId = PageId(j.getString("pageId"));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.trigger = j.getString("trigger");
            dto.triggerConfig = j.getString("triggerConfig");
            dto.nodes = j.getString("nodes");
            dto.connections = j.getString("connections");
            dto.variables = j.getString("variables");
            dto.errorHandler = j.getString("errorHandler");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createLogicFlow(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Logic flow created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto j = req.json;

            LogicFlowDTO dto;
            dto.tenantId = tenantId;
            dto.logicFlowId = LogicFlowId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.nodes = j.getString("nodes");
            dto.connections = j.getString("connections");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateLogicFlow(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Logic flow updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = LogicFlowId(extractIdFromPath(path));

            auto result = usecase.deleteLogicFlow(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("message", "Logic flow deleted successfully");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
