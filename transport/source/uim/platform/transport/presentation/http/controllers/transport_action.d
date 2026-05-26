/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.transport_action;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportActionController : ManageController {
    private ManageTransportActionsUseCase usecase;

    this(ManageTransportActionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/transport/actions", &handleList);
        router.get("/api/v1/transport/actions/*", &handleGet);
        router.post("/api/v1/transport/actions", &handleCreate);
        router.put("/api/v1/transport/actions/*", &handleUpdate);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listActions(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            res.writeJsonBody(Json.emptyObject.set("count", items.length).set("resources", jarr), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TransportActionprecheck.id);
            auto item = usecase.getAction(tenantId, id);
            if (item.isNull) { writeError(res, 404, "Transport action not found"); return; }
            res.writeJsonBody(item.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            TransportActionDTO dto;
            dto.actionId = TransportActionId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.actionType = j.getString("actionType");
            dto.nodeId = j.getString("nodeId");
            dto.requestId = j.getString("requestId");
            dto.routeId = j.getString("routeId");
            dto.performedBy = j.getString("performedBy");
            dto.description = j.getString("description");
            dto.logDetails = j.getString("logDetails");
            auto result = usecase.recordAction(dto);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport action recorded"), 201);
            else
                writeError(res, 400, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TransportActionprecheck.id);
            auto j = req.json;
            auto statusStr = j.getString("actionStatus");
            if (statusStr.length > 0) {
                import std.conv : to;
                try {
                    auto status = statusStr.to!ActionStatus;
                    auto errorMsg = j.getString("errorMessage");
                    auto result = usecase.updateActionStatus(tenantId, id, status, errorMsg);
                    if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Action status updated"), 200);
                    else writeError(res, 400, result.message);
                } catch (Exception) {
                    writeError(res, 400, "Invalid actionStatus value");
                }
            } else {
                writeError(res, 400, "actionStatus field is required");
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
