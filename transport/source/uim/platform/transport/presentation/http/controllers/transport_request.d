/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.transport_request;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportRequestController : ManageHttpController {
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
            auto list = items.map!(e => e.toJson).array.toJson;
            res.writeJsonBody(Json.emptyObject.set("count", items.length).set("resources", jarr), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = TransportRequestId(precheck.id);
            auto item = usecase.getRequest(tenantId, id);
            if (item.isNull) { writeError(res, 404, "Transport request not found"); return; }
            res.writeJsonBody(item.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            TransportRequestDTO dto;
            dto.requestId = TransportRequestId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.externalId = data.getString("externalId");
            dto.contentType = data.getString("contentType");
            dto.version_ = data.getString("version");
            dto.contentSize = data.getString("contentSize");
            dto.storageUrl = data.getString("storageUrl");
            dto.checksum = data.getString("checksum");
            dto.sourceNodeId = data.getString("sourceNodeId");
            dto.namedUser = data.getString("namedUser");
            dto.systemId = data.getString("systemId");
            dto.createdBy = UserId(data.getString("createdBy"));
            auto result = usecase.createRequest(dto);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport request created"), 201);
            else
                writeError(res, 400, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = TransportRequestId(precheck.id);
            auto data = precheck.data;
            auto statusStr = data.getString("status");
            if (statusStr.length > 0) {
                
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

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = TransportRequestId(precheck.id);
            auto result = usecase.deleteRequest(tenantId, id);
            if (result.success) res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Transport request deleted"), 200);
            else writeError(res, 404, result.message);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
