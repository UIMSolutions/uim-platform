/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.subscription;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class SubscriptionController : PlatformController {
    private ManageSubscriptionsUseCase uc;

    this(ManageSubscriptionsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/event-mesh/subscriptions", &handleList);
        router.get("/api/v1/event-mesh/subscriptions/*", &handleGet);
        router.post("/api/v1/event-mesh/subscriptions", &handleCreate);
        router.put("/api/v1/event-mesh/subscriptions/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/subscriptions/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items) jarr ~= subscriptionToJson(e);
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
            auto e = uc.get_(SubscriptionId(id));
            if (e is null) { writeError(res, 404, "Subscription not found"); return; }
            res.writeJsonBody(subscriptionToJson(*e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            SubscriptionDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.brokerServiceId = j.getString("brokerServiceId");
            dto.topicId = j.getString("topicId");
            dto.queueId = j.getString("queueId");
            dto.applicationId = j.getString("applicationId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.topicFilter = j.getString("topicFilter");
            dto.selector = j.getString("selector");
            dto.maxRedeliveryCount = j.getString("maxRedeliveryCount");
            dto.maxTtl = j.getString("maxTtl");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Subscription created");
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
            SubscriptionDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.topicFilter = j.getString("topicFilter");
            dto.selector = j.getString("selector");
            dto.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Subscription updated");
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
            auto result = uc.remove(SubscriptionId(id));
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["message"] = Json("Subscription deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
