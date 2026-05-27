/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.transport_request;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportRequestController : ManageController {
    private ManageTransportRequestsUseCase usecase;

    this(ManageTransportRequestsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/transport/requests", &handleList);
        router.get("/api/v1/transport/requests/*", &handleGet);
        router.post("/api/v1/transport/requests", &handleCreate);
        router.put("/api/v1/transport/requests/*", &handleUpdate);
        router.delete_("/api/v1/transport/requests/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listRequests(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            res.writeJsonBody(Json.emptyObject.set("count", items.length).set("resources", jarr), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TransportRequestprecheck.id);
            auto item = usecase.getRequest(tenantId, id);
            if (item.isNull) { writeError(res, 404, "Transport request not found"); return; }
            res.writeJsonBody(item.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            TransportRequestDTO dto;
            dto.requestId = TransportRequestId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.externalId = j.getString("externalId");
            dto.contentType = j.getString("contentType");
            dto.version_ = j.getString("version");
            dto.contentSize = j.getString("contentSize");
            dto.storageUrl = j.getString("storageUrl");
            dto.checksum = j.getString("checksum");
            dto.sourceNodeId = j.getString("sourceNodeId");
            dto.namedUser = j.getString("namedUser");
            dto.systemId = j.getString("systemId");
            dto.createdBy = UserId(j.getString("createdBy"));
            auto result = usecase.createRequest(dto);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport request created"), 201);
            else
                writeError(res, 400, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TransportRequestprecheck.id);
            auto j = req.json;
            auto statusStr = j.getString("status");
            if (statusStr.length > 0) {
                import std.conv : to;
                try {
                    auto status = statusStr.to!RequestStatus;
                    auto result = usecase.updateRequestStatus(tenantId, id, status);
                    if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Status updated"), 200);
                    else writeError(res, 400, result.message);
                } catch (Exception) {
                    writeError(res, 400, "Invalid status value");
                }
            } else {
                writeError(res, 400, "status field is required");
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TransportRequestprecheck.id);
            auto result = usecase.deleteRequest(tenantId, id);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport request deleted"), 200);
            else writeError(res, 404, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
