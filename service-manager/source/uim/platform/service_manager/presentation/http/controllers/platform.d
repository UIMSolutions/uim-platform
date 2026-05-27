module uim.platform.service_manager.presentation.http.controllers.platform;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class EnvironmentController : ManageController {
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
                .set("totalCount", items.length)
                .set("message", "Platforms retrieved successfully");

            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto tenantId = precheck.tenantId;
            auto id = precheck.id;
            auto e = usecase.getById(tenantId, PlatformId(id));
            if (e.isNull) {
                writeError(res, 404, "Platform not found");
                return;
            }
            res.writeJsonBody(Json.emptyObject
                    .set("id", e.id.value).set("name", e.name)
                    .set("description", e.description)
                    .set("type", e.type.to!string)
                    .set("status", e.status.to!string)
                    .set("brokerUrl", e.brokerUrl)
                    .set("region", e.region)
                    .set("subaccountId", e.subaccountId)
                    .set("createdAt", e.createdAt), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
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
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Platform created successfully");

                res.writeJsonBody(response, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

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
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto id = precheck.id;
            auto result = usecase.deletePlatform(req.getTenantId, PlatformId(id));
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject, 204);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
