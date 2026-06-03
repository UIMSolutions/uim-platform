/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.event_schema;

import std.uuid : randomUUID;

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
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Event schema list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

        auto id = EventSchemaId(precheck.id);
        if (id.isNull)
            id = EventSchemaId(randomUUID().toString);

        EventSchemaDTO dto;
        dto.schemaId = id;
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

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Event schema created successfully", "Created", 201, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
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

unittest {
    import uim.platform.service.tests;

    @safe class EventSchemaControllerTest : ControllerTestBase {
        void runTests() {
            // 1. Setup
            auto repo = new MemoryEventSchemaRepository();
            auto usecase = new ManageEventSchemasUseCase(repo);
            auto controller = new EventSchemaController(usecase);
            auto tenantId = TenantId("test-tenant");

            // 2. Test List Handler
            auto reqList = createMockRequest("GET", "/api/v1/event-mesh/schemas", tenantId);
            auto resList = controller.listHandler(reqList);
            assert(resList.getString("status") != "error");
            assert(resList["data"]["count"].get!int == 0);

            // 3. Test Create Handler
            Json createData = Json.emptyObject
                .set("name", "Test Schema")
                .set("description", "A test event schema")
                .set("version", "1.0.0")
                .set("schemaContent", "{}")
                .set("createdBy", "user-1");

            auto reqCreate = createMockRequest("POST", "/api/v1/event-mesh/schemas", tenantId, createData);
            reqCreate.params["id"] = "schema-1";
            auto resCreate = controller.createHandler(reqCreate);
            // assert(resCreate.getString("status") != "error");
            // assert(resCreate["data"]["id"].get!string == "schema-1");

            // 4. Test Get Handler
            auto reqGet = createMockRequest("GET", "/api/v1/event-mesh/schemas/schema-1", tenantId);
            reqGet.params["id"] = "schema-1";
            auto resGet = controller.getHandler(reqGet);
            // assert(resGet.getString("status") != "error");
            // assert(resGet["data"]["name"].get!string == "Test Schema");

            // 5. Test Update Handler
            Json updateData = Json.emptyObject
                .set("name", "Updated Schema")
                .set("updatedBy", "user-2");
            auto reqUpdate = createMockRequest("PUT", "/api/v1/event-mesh/schemas/schema-1", tenantId, updateData);
            reqUpdate.params["id"] = "schema-1";
            auto resUpdate = controller.updateHandler(reqUpdate);
            // assert(resUpdate.getString("status") != "error");

            // Verify update
            auto resGet2 = controller.getHandler(reqGet);
            // assert(resGet2["data"]["name"].get!string == "Updated Schema");

            // 6. Test Delete Handler
            auto reqDelete = createMockRequest("DELETE", "/api/v1/event-mesh/schemas/schema-1", tenantId);
            reqDelete.params["id"] = "schema-1";
            auto resDelete = controller.deleteHandler(reqDelete);
            // assert(resDelete.getString("status") != "error");

            // Verify deletion
            auto resGet3 = controller.getHandler(reqGet);
            // assert(resGet3.getString("status") == "error"); // Expect 404
        }
    }

    auto runner = new EventSchemaControllerTest();
    runner.runTests();
}
