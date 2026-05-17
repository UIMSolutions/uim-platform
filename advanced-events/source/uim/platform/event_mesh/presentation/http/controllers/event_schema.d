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
    private ManageEventSchemasUseCase usecase;

    this(ManageEventSchemasUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/event-mesh/schemas", &handleList);
        router.get("/api/v1/event-mesh/schemas/*", &handleGet);
        router.post("/api/v1/event-mesh/schemas", &handleCreate);
        router.put("/api/v1/event-mesh/schemas/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/schemas/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto items = usecase.listSchemas(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Event schema list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = EventSchemaId(extractIdFromPath(path));

            auto schema = usecase.getSchema(tenantId, id);
            if (schema.isNull) {
                writeError(res, 404, "Event schema not found");
                return;
            }

            res.writeJsonBody(schema.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            EventSchemaDTO dto;
            dto.schemaId = EventSchemaId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.version_ = j.getString("version");
            dto.schemaContent = j.getString("schemaContent");
            // TODO: dto.applicationDomainId = ApplicationDomainId(j.getString("applicationDomainId"));
            dto.shared_ = j.getString("shared");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createSchema(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Event schema created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;

            EventSchemaDTO dto;
            dto.schemaId = EventSchemaId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.schemaContent = j.getString("schemaContent");
            dto.version_ = j.getString("version");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateSchema(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Event schema updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = EventSchemaId(extractIdFromPath(path));

            auto result = usecase.deleteSchema(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", "Event schema deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
