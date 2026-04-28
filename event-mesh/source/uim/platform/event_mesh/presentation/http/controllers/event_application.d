/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.event_application;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class EventApplicationController : PlatformController {
    private ManageEventApplicationsUseCase uc;

    this(ManageEventApplicationsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/event-mesh/applications", &handleList);
        router.get("/api/v1/event-mesh/applications/*", &handleGet);
        router.post("/api/v1/event-mesh/applications", &handleCreate);
        router.put("/api/v1/event-mesh/applications/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/applications/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items) jarr ~= eventApplicationToJson(e);
            auto resp = Json.emptyObject;
            resp["count"] = Json(items.length);
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
            auto e = uc.getById(EventApplicationId(id));
            if (e.isNull) { writeError(res, 404, "Event application not found"); return; }
            res.writeJsonBody(eventApplicationToJson(*e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            EventApplicationDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.brokerServiceId = j.getString("brokerServiceId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.applicationDomainId = j.getString("applicationDomainId");
            dto.clientUsername = j.getString("clientUsername");
            dto.clientProfile = j.getString("clientProfile");
            dto.aclProfile = j.getString("aclProfile");
            dto.version_ = j.getString("version");
            dto.publishTopics = j.getString("publishTopics");
            dto.subscribeTopics = j.getString("subscribeTopics");
            dto.webhookUrl = j.getString("webhookUrl");
            dto.maxConnections = j.getString("maxConnections");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Event application created");
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
            EventApplicationDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.clientUsername = j.getString("clientUsername");
            dto.clientProfile = j.getString("clientProfile");
            dto.aclProfile = j.getString("aclProfile");
            dto.publishTopics = j.getString("publishTopics");
            dto.subscribeTopics = j.getString("subscribeTopics");
            dto.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Event application updated");
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
            auto result = uc.remove(EventApplicationId(id));
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["message"] = Json("Event application deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
