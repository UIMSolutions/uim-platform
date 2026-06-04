module uim.platform.service_manager.presentation.http.controllers.service_broker;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ServiceBrokerController : ManageHttpController {
    private ManageServiceBrokersUseCase usecase;

    this(ManageServiceBrokersUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/service-manager/service-brokers", &handleList);
        router.get("/api/v1/service-manager/service-brokers/*", &handleGet);
        router.post("/api/v1/service-manager/service-brokers", &handleCreate);
        router.put("/api/v1/service-manager/service-brokers/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/service-brokers/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listByTenant(tenantId);
        auto list = Json.emptyArray;
        foreach (e; items) {
            list ~= Json.emptyObject
                .set("id", e.id.value).set("name", e.name)
                .set("description", e.description)
                .set("brokerUrl", e.brokerUrl)
                .set("status", e.status.to!string);
        }

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Service brokers retrieved successfully", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto tenantId = precheck.tenantId;
        auto id = ServiceBrokerId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service broker ID", 400);

        auto e = usecase.getById(tenantId, ServiceBrokerId(id));
        if (e.isNull)
            return errorResponse("Service broker not found", 404);

        auto responseData = Json.emptyObject
            .set("id", e.id.value).set("name", e.name)
            .set("description", e.description)
            .set("brokerUrl", e.brokerUrl)
            .set("status", e.status.to!string)
            .set("createdAt", e.createdAt);
        return successResponse("Service broker retrieved successfully", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateServiceBrokerRequest r;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.brokerUrl = data.getString("brokerUrl");

        auto result = usecase.create(req.getTenantId, r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service broker created successfully", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ServiceBrokerId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service broker ID", 400);

        auto data = precheck.data;
        UpdateServiceBrokerRequest r;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.brokerUrl = data.getString("brokerUrl");

        auto result = usecase.update(req.getTenantId, ServiceBrokerId(id), r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service broker updated successfully", 200, Json.emptyObject.set("id", id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServiceBrokerId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service broker ID", 400);

        auto result = usecase.delete(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Service broker deleted successfully", 200, Json.emptyObject.set("id", id));
    }
}
