/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.topic;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class TopicController : PlatformController {
    private ManageTopicsUseCase uc;

    this(ManageTopicsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/event-mesh/topics", &handleList);
        router.get("/api/v1/event-mesh/topics/*", &handleGet);
        router.post("/api/v1/event-mesh/topics", &handleCreate);
        router.put("/api/v1/event-mesh/topics/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/topics/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = items.map!(e => topicToJson(e)).array;
            
            auto resp = Json.emptyObject
              .set("count", Json(items.length))
              .set("resources", jarr);

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
            auto e = uc.getById(TopicId(id));
            if (e.isNull) { writeError(res, 404, "Topic not found"); return; }
            res.writeJsonBody(topicToJson(e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            TopicDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.brokerServiceId = j.getString("brokerServiceId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.topicString = j.getString("topicString");
            dto.maxMessageSize = j.getString("maxMessageSize");
            dto.publishEnabled = j.getString("publishEnabled");
            dto.subscribeEnabled = j.getString("subscribeEnabled");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", Json(result.id))
                  .set("message", Json("Topic created"));

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
            TopicDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.topicString = j.getString("topicString");
            dto.maxMessageSize = j.getString("maxMessageSize");
            dto.updatedBy = j.getString("updatedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", Json(result.id))
                  .set("message", Json("Topic updated"));

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
            auto result = uc.remove(TopicId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", Json("Topic deleted"));
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
