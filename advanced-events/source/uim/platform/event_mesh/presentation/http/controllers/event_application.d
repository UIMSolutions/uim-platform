/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.http.controllers.event_application;

import std.uuid : randomUUID;

import uim.platform.event_mesh;
mixin(ShowModule!());

@safe:

class EventApplicationController : ManageHttpController {
    private ManageEventApplicationsUseCase usecase;

    this(ManageEventApplicationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/event-mesh/applications", &handleList);
        router.get("/api/v1/event-mesh/applications/*", &handleGet);
        router.post("/api/v1/event-mesh/applications", &handleCreate);
        router.put("/api/v1/event-mesh/applications/*", &handleUpdate);
        router.delete_("/api/v1/event-mesh/applications/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listApplications(tenantId);
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Event application list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

        auto createId = precheck.id;
        if (createId.isEmpty)
            createId = data.getString("id");
        if (createId.isEmpty) {
            try {
                createId = req.params["id"];
            } catch (Exception) {
            }
        }
        if (createId.isEmpty)
            createId = randomUUID().toString();

        EventApplicationDTO dto;
        dto.applicationId = EventApplicationId(createId);
        dto.tenantId = tenantId;
        dto.serviceId = BrokerServiceId(data.getString("serviceId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.applicationDomainId = data.getString("applicationDomainId");
        dto.clientUsername = data.getString("clientUsername");
        dto.clientProfile = data.getString("clientProfile");
        dto.aclProfile = data.getString("aclProfile");
        dto.version_ = data.getString("version");
        dto.publishTopics = data.getString("publishTopics");
        dto.subscribeTopics = data.getString("subscribeTopics");
        dto.webhookUrl = data.getString("webhookUrl");
        dto.maxConnections = data.getString("maxConnections");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createApplication(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Event application created successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = EventApplicationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid event application ID", 400);

        auto e = usecase.getApplication(tenantId, id);
        if (e.isNull)
            return errorResponse("Event application not found", 404);

        auto responseData = e.toJson();
        return successResponse("Event application retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = EventApplicationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid event application ID", 400);

        EventApplicationDTO dto;
        dto.tenantId = tenantId;
        dto.applicationId = id;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.clientUsername = data.getString("clientUsername");
        dto.clientProfile = data.getString("clientProfile");
        dto.aclProfile = data.getString("aclProfile");
        dto.publishTopics = data.getString("publishTopics");
        dto.subscribeTopics = data.getString("subscribeTopics");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateApplication(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Event application updated successfully", "Updated", 200, responseData);

    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = EventApplicationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid event application ID", 400);

        auto result = usecase.deleteApplication(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Event application deleted successfully", "Deleted", 200, responseData);
    }
}
