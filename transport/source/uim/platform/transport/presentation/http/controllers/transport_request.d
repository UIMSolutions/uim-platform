/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.transport_request;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportRequestController : PlatformController {
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

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listRequests(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            res.writeJsonBody(Json.emptyObject.set("count", items.length).set("resources", jarr), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TransportRequestId(extractIdFromPath(req.requestURI.to!string));
            auto item = usecase.getRequest(tenantId, id);
            if (item.isNull) { writeError(res, 404, "Transport request not found"); return; }
            res.writeJsonBody(item.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            TransportRequestDTO dto;
            dto.requestId = TransportRequestId(j.getString("id"));
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
                writeError(res, 400, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TransportRequestId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;
            auto statusStr = j.getString("status");
            if (statusStr.length > 0) {
                import std.conv : to;
                try {
                    auto status = statusStr.to!RequestStatus;
                    auto result = usecase.updateRequestStatus(tenantId, id, status);
                    if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Status updated"), 200);
                    else writeError(res, 400, result.error);
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

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TransportRequestId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteRequest(tenantId, id);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport request deleted"), 200);
            else writeError(res, 404, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
