/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.presentation.http.event_subscription;

// import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.kyma.application.usecases.manage_event_subscriptions;
import uim.platform.kyma.application.dto;
import uim.platform.kyma.domain.entities.event_subscription;
import uim.platform.kyma.domain.types;
import uim.platform.kyma.presentation.http.json_utils;

class EventSubscriptionController {
    private ManageEventSubscriptionsUseCase uc;

    this(ManageEventSubscriptionsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        router.post("/api/v1/event-subscriptions", &handleCreate);
        router.get("/api/v1/event-subscriptions", &handleList);
        router.get("/api/v1/event-subscriptions/*", &handleGetById);
        router.put("/api/v1/event-subscriptions/*", &handleUpdate);
        router.delete_("/api/v1/event-subscriptions/*", &handleDelete);
        router.post("/api/v1/event-subscriptions/pause/*", &handlePause);
        router.post("/api/v1/event-subscriptions/resume/*", &handleResume);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateEventSubscriptionRequest r;
            r.namespaceId = j.getString("namespaceId");
            r.environmentId = j.getString("environmentId");
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.source = j.getString("source");
            r.eventTypes = jsonStrArray(j, "eventTypes");
            r.typeEncoding = j.getString("typeEncoding");
            r.sinkUrl = j.getString("sinkUrl");
            r.sinkServiceName = j.getString("sinkServiceName");
            r.sinkServicePort = j.getInteger("sinkServicePort");
            r.maxInFlightMessages = j.getInteger("maxInFlightMessages");
            r.exactTypeMatching = j.getBoolean("exactTypeMatching", true);
            r.filterAttributes = jsonStrMap(j, "filterAttributes");
            r.labels = jsonStrMap(j, "labels");
            r.createdBy = req.headers.get("X-User-Id", "");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            } else
                writeError(res, 400, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto nsId = req.params.get("namespaceId");
            auto envId = req.params.get("environmentId");
            auto source = req.params.get("source");

            EventSubscription[] items;
            if (source.length > 0)
                items = uc.listBySource(source);
            else if (nsId.length > 0)
                items = uc.listByNamespace(nsId);
            else if (envId.length > 0)
                items = uc.listByEnvironment(envId);
            else
                items = [];

            auto arr = Json.emptyArray;
            foreach (ref sub; items)
                arr ~= serializeSub(sub);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)items.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto sub = uc.getSubscription(id);
            if (sub.id.length == 0) {
                writeError(res, 404, "Subscription not found");
                return;
            }
            res.writeJsonBody(serializeSub(sub), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            UpdateEventSubscriptionRequest r;
            r.description = j.getString("description");
            r.eventTypes = jsonStrArray(j, "eventTypes");
            r.sinkUrl = j.getString("sinkUrl");
            r.sinkServiceName = j.getString("sinkServiceName");
            r.sinkServicePort = j.getInteger("sinkServicePort");
            r.maxInFlightMessages = j.getInteger("maxInFlightMessages");
            r.exactTypeMatching = j.getBoolean("exactTypeMatching", true);
            r.filterAttributes = jsonStrMap(j, "filterAttributes");
            r.labels = jsonStrMap(j, "labels");

            auto result = uc.updateSubscription(id, r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 200);
            else
                writeError(res, 400, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handlePause(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.pauseSubscription(id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 200);
            else
                writeError(res, 400, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleResume(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.resumeSubscription(id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 200);
            else
                writeError(res, 400, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.deleteSubscription(id);
            if (result.success)
                res.writeBody("", 204);
            else
                writeError(res, 404, result.error);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json serializeSub(ref EventSubscription sub) {
        auto j = Json.emptyObject;
        j["id"] = Json(sub.id);
        j["namespaceId"] = Json(sub.namespaceId);
        j["environmentId"] = Json(sub.environmentId);
        j["tenantId"] = Json(sub.tenantId);
        j["name"] = Json(sub.name);
        j["description"] = Json(sub.description);
        j["status"] = Json(sub.status.to!string);
        j["source"] = Json(sub.source);
        j["eventTypes"] = serializeStrArray(sub.eventTypes);
        j["typeEncoding"] = Json(sub.typeEncoding.to!string);
        j["sinkUrl"] = Json(sub.sinkUrl);
        j["sinkServiceName"] = Json(sub.sinkServiceName);
        j["sinkServicePort"] = Json(cast(long)sub.sinkServicePort);
        j["maxInFlightMessages"] = Json(cast(long)sub.maxInFlightMessages);
        j["exactTypeMatching"] = Json(sub.exactTypeMatching);
        j["filterAttributes"] = serializeStrMap(sub.filterAttributes);
        j["labels"] = serializeStrMap(sub.labels);
        j["createdBy"] = Json(sub.createdBy);
        j["createdAt"] = Json(sub.createdAt);
        j["modifiedAt"] = Json(sub.modifiedAt);
        return j;
    }
}
