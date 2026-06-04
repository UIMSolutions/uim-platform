module uim.platform.service_manager.presentation.http.controllers.platform;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class PlatformController : ManageHttpController {
    private ManagePlatformsUseCase usecase;

    this(ManagePlatformsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/service-manager/platforms", &handleList);
        router.get("/api/v1/service-manager/platforms/*", &handleGet);
        router.post("/api/v1/service-manager/platforms", &handleCreate);
        router.put("/api/v1/service-manager/platforms/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/platforms/*", &handleDelete);
    }

    /**
        * Handles the HTTP GET request to list all platforms for the tenant.
        * It retrieves the tenant ID from the request, fetches the list of platforms using the use case, and constructs a JSON response containing the platform details and total count.
        * If any exception occurs during processing, it returns a 500 Internal Server Error response.
        *
        * @param req The HTTP request object containing details of the incoming request.
        * @param res The HTTP response object used to send back the response to the client.
        */
    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listByTenant(tenantId);
        auto jarr = Json.emptyArray;
        foreach (e; items) {
            jarr ~= Json.emptyObject
                .set("id", e.id.value).set("name", e.name)
                .set("description", e.description)
                .set("type", e.type.to!string)
                .set("status", e.status.to!string)
                .set("region", e.region);
        }

        auto response = Json.emptyObject
            .set("items", jarr)
            .set("totalCount", items.length);

        return successResponse("Platforms retrieved successfully", 200, response);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = PlatformId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid platform ID", 400);

        auto e = usecase.getPlatform(tenantId, id);
        if (e.isNull)
            return errorResponse("Platform not found", 404);

        auto responseData = Json.emptyObject
            .set("id", e.id.value).set("name", e.name)
            .set("description", e.description)
            .set("type", e.type.to!string)
            .set("status", e.status.to!string)
            .set("brokerUrl", e.brokerUrl)
            .set("region", e.region)
            .set("subaccountId", e.subaccountId)
            .set("createdAt", e.createdAt);

        return successResponse("Platform retrieved successfully", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreatePlatformRequest r;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.type = data.getString("type");
        r.brokerUrl = data.getString("brokerUrl");
        r.credentials = data.getString("credentials");
        r.region = data.getString("region");
        r.subaccountId = data.getString("subaccountId");

        auto result = usecase.create(req.getTenantId, r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto response = Json.emptyObject.set("id", result.id);
        return successResponse("Platform created successfully", 201, response);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = precheck.id;
        auto data = precheck.data;
        UpdatePlatformRequest r;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.type = data.getString("type");
        r.brokerUrl = data.getString("brokerUrl");
        r.credentials = data.getString("credentials");
        r.region = data.getString("region");

        auto result = usecase.update(req.getTenantId, PlatformId(id), r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Platform updated successfully", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = precheck.id;
        auto result = usecase.deletePlatform(req.getTenantId, PlatformId(id));
        if (result.hasError)
            return errorResponse(result.message, 400);
        
        auto responseData = Json.emptyObject.set("id", id);
        return successResponse("Platform deleted successfully", 200, responseData);
    }
}
