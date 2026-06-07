module uim.platform.data_retention.presentation.http.controllers.legal_entity;
import uim.platform.data_retention;

// mixin(ShowModule!());

@safe:

class LegalEntityController : ManageHttpController {
    private ManageLegalEntitiesUseCase usecase;

    this(ManageLegalEntitiesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/data-retention/legal-entities", &handleCreate);
        router.get("/api/v1/data-retention/legal-entities", &handleList);
        router.get("/api/v1/data-retention/legal-entities/*", &handleGet);
        router.put("/api/v1/data-retention/legal-entities/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/legal-entities/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateLegalEntityRequest r;
        r.tenantId = tenantId;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.country = data.getString("country");
        r.region = data.getString("region");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createLegalEntity(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Legal entity created successfully", "Created", 201, Json.emptyObject.set("id", result
                .id));
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listLegalEntity(tenantId);
        auto jarr = Json.emptyArray;
        foreach (le; items) {
            jarr ~= Json.emptyObject
                .set("id", le.id.value).set("name", le.name)
                .set("description", le.description)
                .set("country", le.country)
                .set("isActive", le.isActive);
        }

        auto responseData = Json.emptyObject
            .set("count", jarr.length)
            .set("resources", jarr);
        return successResponse("Legal entity list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = LegalEntityId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid legal entity ID", 400);

        auto le = usecase.getLegalEntity(tenantId, id);
        if (le.isNull)
            return errorResponse("Legal entity not found", 404);

        auto responseData = Json.emptyObject
            .set("id", le.id.value).set("name", le.name)
            .set("description", le.description)
            .set("country", le.country).set("region", le.region)
            .set("isActive", le.isActive);

        return successResponse("Legal entity retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = LegalEntityId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid legal entity ID", 400);

        auto data = precheck.data;
        UpdateLegalEntityRequest r;
        r.tenantId = tenantId;
        r.entityId = id;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.country = data.getString("country");
        r.region = data.getString("region");
        r.isActive = data.getBoolean("isActive", true);

        auto result = usecase.updateLegalEntity(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Legal entity updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = LegalEntityId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid legal entity ID", 400);

        auto result = usecase.deleteLegalEntity(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Legal entity deleted successfully", "Deleted", 200, responseData);
    }
}
