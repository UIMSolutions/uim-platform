/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.event_schema;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class EventSchemaController : ManageController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listSchemas(tenantId);
        auto jarr = items.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr);

        return successResponse("Event schema list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        EventSchemaDTO dto;
        dto.schemaId = EventSchemaId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.version_ = data.getString("version");
        dto.schemaContent = data.getString("schemaContent");
        // TODO: dto.applicationDomainId = ApplicationDomainId(data.getString("applicationDomainId"));
        dto.shared_ = data.getString("shared");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createSchema(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("id", result.id);

        return successResponse("Event schema created successfully", "Created", 201, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = EventSchemaId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid event schema ID", 400);

        auto schema = usecase.getSchema(tenantId, id);
        if (schema.isNull)
            return errorResponse("Event schema not found", 404);

        return successResponse("Event schema retrieved successfully", "Retrieved", 200, schema
                .toJson);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        EventSchemaDTO dto;
        dto.schemaId = EventSchemaId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.schemaContent = data.getString("schemaContent");
        dto.version_ = data.getString("version");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateSchema(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Event schema updated");

        return successResponse("Event schema updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = EventSchemaId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid event schema ID", 400);

        auto result = usecase.deleteSchema(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        auto resp = Json.emptyObject
            .set("id", id);

        return successResponse("Event schema deleted successfully", "Deleted", 200, resp);
    }
}
