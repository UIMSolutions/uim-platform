/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.transport_node;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportNodeController : ManageController {
    private ManageTransportNodesUseCase usecase;

    this(ManageTransportNodesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/transport/nodes", &handleList);
        router.get("/api/v1/transport/nodes/*", &handleGet);
        router.post("/api/v1/transport/nodes", &handleCreate);
        router.put("/api/v1/transport/nodes/*", &handleUpdate);
        router.delete_("/api/v1/transport/nodes/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listNodes(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            res.writeJsonBody(Json.emptyObject.set("count", items.length).set("resources", jarr), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = TransportNodeprecheck.id);
            auto item = usecase.getNode(tenantId, id);
            if (item.isNull) { writeError(res, 404, "Transport node not found"); return; }
            res.writeJsonBody(item.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto j = req.json;
            TransportNodeDTO dto;
            dto.nodeId = TransportNodeId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.nodeType = data.getString("nodeType");
            dto.environment = data.getString("environment");
            dto.region = data.getString("region");
            dto.globalAccount = data.getString("globalAccount");
            dto.subaccountId = data.getString("subaccountId");
            dto.spaceId = data.getString("spaceId");
            dto.serviceKey = data.getString("serviceKey");
            dto.isForwardEnabled = getBoolean(j, "isForwardEnabled");
            dto.autoImport = getBoolean(j, "autoImport");
            dto.autoImportSchedule = data.getString("autoImportSchedule");
            dto.createdBy = UserId(data.getString("createdBy"));
            auto result = usecase.createNode(dto);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport node created"), 201);
            else
                writeError(res, 400, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = TransportNodeprecheck.id);
            auto j = req.json;
            auto action = data.getString("action");
            if (action == "enable") {
                auto result = usecase.enableNode(tenantId, id);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Node enabled"), 200);
                else writeError(res, 400, result.message);
                return;
            }
            if (action == "disable") {
                auto result = usecase.disableNode(tenantId, id);
                if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Node disabled"), 200);
                else writeError(res, 400, result.message);
                return;
            }
            TransportNodeDTO dto;
            dto.nodeId = id;
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.region = data.getString("region");
            dto.environment = data.getString("environment");
            dto.isForwardEnabled = getBoolean(j, "isForwardEnabled");
            dto.autoImport = getBoolean(j, "autoImport");
            dto.autoImportSchedule = data.getString("autoImportSchedule");
            dto.updatedBy = UserId(data.getString("updatedBy"));
            auto result = usecase.updateNode(dto);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport node updated"), 200);
            else writeError(res, 400, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = TransportNodeprecheck.id);
            auto result = usecase.deleteNode(tenantId, id);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport node deleted"), 200);
            else writeError(res, 404, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
