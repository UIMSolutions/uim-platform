/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.event_schema;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class EventSchemaController : PlatformController {
    private ManageEventSchemasUseCase uc;

    this(ManageEventSchemasUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/event-mesh/schemas", &handleList);
        router.get("/api/v1/event-mesh/schemas/*", &handleGet);
        router.post("/api/v1/event-mesh/schemas", &handleCreate);
        router.put("/api/v1/event-mesh/schemas/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/schemas/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = items.map!(e => eventSchemaToJson(e)).array;
            
            auto resp = Json.emptyObject
              .set("count", Json(items.length))
              .set("resources", jarr)
              .set("message", Json("Event schema list retrieved successfully"));

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
            auto e = uc.getById(EventSchemaId(id));
            if (e.isNull) { writeError(res, 404, "Event schema not found"); return; }
            res.writeJsonBody(eventSchemaToJson(*e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            EventSchemaDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.version_ = j.getString("version");
            dto.schemaContent = j.getString("schemaContent");
            dto.applicationDomainId = j.getString("applicationDomainId");
            dto.shared_ = j.getString("shared");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", Json(result.id))
                  .set("message", Json("Event schema created"));
                  
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
            EventSchemaDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.schemaContent = j.getString("schemaContent");
            dto.version_ = j.getString("version");
            dto.updatedBy = j.getString("updatedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", Json(result.id))
                  .set("message", Json("Event schema updated"));

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
            auto result = uc.remove(EventSchemaId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", Json("Event schema deleted"));
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
