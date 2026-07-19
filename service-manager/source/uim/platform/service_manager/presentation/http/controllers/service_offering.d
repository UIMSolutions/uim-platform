module uim.platform.service_manager.presentation.http.controllers.service_offering;

import uim.platform.service_manager;
mixin(ShowModule!());

@safe:

class ServiceOfferingController : ManageHttpController {
    private ManageServiceOfferingsUseCase usecase;

    this(ManageServiceOfferingsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/service-manager/service-offerings", &handleList);
        router.get("/api/v1/service-manager/service-offerings/*", &handleGet);
        router.post("/api/v1/service-manager/service-offerings", &handleCreate);
        router.put("/api/v1/service-manager/service-offerings/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/service-offerings/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listOfferings(tenantId);
        auto list = Json.emptyArray;
        foreach (e; items) {
            list ~= Json.emptyObject
                .set("id", e.id.value).set("name", e.name)
                .set("description", e.description)
                .set("catalogName", e.catalogName)
                .set("status", e.status.to!string)
                .set("category", e.category.to!string);
        }
        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Service offerings retrieved successfully", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServiceOfferingId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service offering ID", 400);

        auto e = usecase.getOffering(tenantId, id);
        if (e.isNull)
            return errorResponse("Service offering not found", 404);

        auto responseData = Json.emptyObject
            .set("id", e.id.value)
            .set("name", e.name)
            .set("description", e.description)
            .set("catalogName", e.catalogName)
            .set("brokerId", e.brokerId.value)
            .set("status", e.status.to!string)
            .set("category", e.category.to!string)
            .set("bindable", e.bindable)
            .set("tags", e.tags)
            .set("createdAt", e.createdAt);

        return successResponse("Service offering retrieved successfully", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateServiceOfferingRequest r;
        r.tenantId = tenantId;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.catalogName = data.getString("catalogName");
        r.brokerId = data.getString("brokerId");
        r.category = data.getString("category");
        r.tags = data.getString("tags");
        r.metadata = data.getString("metadata");

        auto result = usecase.createOffering(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service offering created successfully", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServiceOfferingId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service offering ID", 400);

        auto data = precheck.data;
        UpdateServiceOfferingRequest r;
        r.tenantId = tenantId;
        r.offeringId = id;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.catalogName = data.getString("catalogName");
        r.tags = data.getString("tags");
        r.metadata = data.getString("metadata");

        auto result = usecase.updateOffering(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service offering updated successfully", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ServiceOfferingId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service offering ID", 400);

        auto result = usecase.deleteOffering(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service offering deleted successfully", 200, responseData);
    }
}
