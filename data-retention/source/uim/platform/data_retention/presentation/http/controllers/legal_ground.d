module uim.platform.data_retention.presentation.http.controllers.legal_ground;
import uim.platform.data_retention;
mixin(ShowModule!());

@safe:

class LegalGroundController : ManageHttpController {
    private ManageLegalGroundsUseCase usecase;

    this(ManageLegalGroundsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/data-retention/legal-grounds", &handleCreate);
        router.get("/api/v1/data-retention/legal-grounds", &handleList);
        router.get("/api/v1/data-retention/legal-grounds/*", &handleGet);
        router.put("/api/v1/data-retention/legal-grounds/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/legal-grounds/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateLegalGroundRequest r;
        r.tenantId = tenantId;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.businessPurposeId = BusinessPurposeId(data.getString("businessPurposeId"));
        r.type = data.getString("type");
        r.referenceDate = data.getLong("referenceDate");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createLegalGround(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Legal ground created successfully", "Created", 201, responseData);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listLegalGrounds(tenantId);
        auto list = Json.emptyArray;
        foreach (lg; items) {
            list ~= Json.emptyObject
                .set("id", lg.id.value).set("name", lg.name)
                .set("description", lg.description)
                .set("businessPurposeId", lg.businessPurposeId.value)
                .set("type", lg.type.to!string);
        }

        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Legal grounds retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = LegalGroundId(precheck.id);
        auto lg = usecase.getLegalGround(tenantId, id);
        if (lg.isNull)
            return errorResponse("Legal ground not found", 404);

        auto responseData = Json.emptyObject
            .set("id", lg.id.value).set("name", lg.name)
            .set("description", lg.description)
            .set("businessPurposeId", lg.businessPurposeId.value)
            .set("type", lg.type.to!string)
            .set("referenceDate", lg.referenceDate)
            .set("isActive", lg.isActive);

        return successResponse("Legal ground retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = LegalGroundId(precheck.id);
        auto data = precheck.data;
        UpdateLegalGroundRequest r;
        r.tenantId = tenantId;
        r.legalGroundId = id;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.type = data.getString("type");
        r.referenceDate = data.getLong("referenceDate");

        auto result = usecase.updateLegalGround(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Legal ground updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = LegalGroundId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid legal ground ID", 400);

        auto result = usecase.deleteLegalGround(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Legal ground deleted successfully", "Deleted", 200, responseData);
    }
}
