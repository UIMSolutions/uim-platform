/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.presentation.http.controllers.change_request;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class ChangeRequestController : SAPController {
    private ManageChangeRequestsUseCase uc;

    this(ManageChangeRequestsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/product-development/change-requests", &handleList);
        router.get("/api/v1/product-development/change-requests/*", &handleGet);
        router.post("/api/v1/product-development/change-requests", &handleCreate);
        router.put("/api/v1/product-development/change-requests/*", &handleUpdate);
        router.delete_("/api/v1/product-development/change-requests/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (ref e; items) jarr ~= changeRequestToJson(e);
            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) items.length);
            resp["resources"] = jarr;
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
            auto e = uc.get_(id);
            if (e is null) { writeError(res, 404, "Change request not found"); return; }
            res.writeJsonBody(changeRequestToJson(*e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            ChangeRequestDTO dto;
            dto.id = jsonStr(j, "id");
            dto.tenantId = req.headers.get("X-Tenant-Id", "");
            dto.productId = jsonStr(j, "productId");
            dto.title = jsonStr(j, "title");
            dto.description = jsonStr(j, "description");
            dto.priority = jsonStr(j, "priority");
            dto.category = jsonStr(j, "category");
            dto.reason = jsonStr(j, "reason");
            dto.impact = jsonStr(j, "impact");
            dto.requestedBy = jsonStr(j, "requestedBy");
            dto.assignedTo = jsonStr(j, "assignedTo");
            dto.requestedDate = jsonStr(j, "requestedDate");
            dto.targetDate = jsonStr(j, "targetDate");
            dto.affectedDocuments = jsonStr(j, "affectedDocuments");
            dto.affectedBoms = jsonStr(j, "affectedBoms");
            dto.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Change request created");
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
            ChangeRequestDTO dto;
            dto.id = extractIdFromPath(path);
            dto.title = jsonStr(j, "title");
            dto.description = jsonStr(j, "description");
            dto.priority = jsonStr(j, "priority");
            dto.assignedTo = jsonStr(j, "assignedTo");
            dto.targetDate = jsonStr(j, "targetDate");
            dto.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Change request updated");
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
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["message"] = Json("Change request deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
