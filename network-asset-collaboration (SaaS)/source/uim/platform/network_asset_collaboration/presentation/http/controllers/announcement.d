/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.presentation.http.controllers.announcement;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class AnnouncementController : SAPController {
    private ManageAnnouncementsUseCase uc;

    this(ManageAnnouncementsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/network-asset-collaboration/announcements", &handleList);
        router.get("/api/v1/network-asset-collaboration/announcements/*", &handleGet);
        router.post("/api/v1/network-asset-collaboration/announcements", &handleCreate);
        router.put("/api/v1/network-asset-collaboration/announcements/*", &handleUpdate);
        router.delete_("/api/v1/network-asset-collaboration/announcements/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto params = req.queryParams();
            auto publisherId = params.get("publisherId", "");

            Announcement[] items;
            if (publisherId.length > 0) {
                items = uc.listByPublisher(publisherId);
            } else {
                items = uc.list();
            }

            auto jarr = Json.emptyArray;
            foreach (ref a; items) jarr ~= announcementToJson(a);
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
            auto a = uc.get_(id);
            if (a is null) { writeError(res, 404, "Announcement not found"); return; }
            res.writeJsonBody(announcementToJson(*a), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            AnnouncementDTO dto;
            dto.id = jsonStr(j, "id");
            dto.tenantId = req.headers.get("X-Tenant-Id", "");
            dto.title = jsonStr(j, "title");
            dto.description = jsonStr(j, "description");
            dto.publisherId = jsonStr(j, "publisherId");
            dto.effectiveDate = jsonStr(j, "effectiveDate");
            dto.expiryDate = jsonStr(j, "expiryDate");
            dto.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Announcement created");
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
            AnnouncementDTO dto;
            dto.id = extractIdFromPath(path);
            dto.title = jsonStr(j, "title");
            dto.description = jsonStr(j, "description");
            dto.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Announcement updated");
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
                resp["message"] = Json("Announcement deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
