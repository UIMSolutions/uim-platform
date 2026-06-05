module uim.platform.data_retention.presentation.http.controllers.business_purpose;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class BusinessPurposeController : ManageHttpController {
    private ManageBusinessPurposesUseCase usecase;

    this(ManageBusinessPurposesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/data-retention/business-purposes", &handleCreate);
        router.get("/api/v1/data-retention/business-purposes", &handleList);
        router.get("/api/v1/data-retention/business-purposes/*", &handleGet);
        router.put("/api/v1/data-retention/business-purposes/*", &handleUpdate);
        router.post("/api/v1/data-retention/business-purposes/*/activate", &handleActivate);
        router.delete_("/api/v1/data-retention/business-purposes/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateBusinessPurposeRequest r;
        r.tenantId = tenantId;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.applicationGroupId = ApplicationGroupId(data.getString("applicationGroupId"));
        r.dataSubjectRoleId = DataSubjectRoleId(data.getString("dataSubjectRoleId"));
        r.legalEntityId = LegalEntityId(data.getString("legalEntityId"));
        r.referenceDate = data.getLong("referenceDate");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createBusinessPurpose(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Business purpose created successfully", "Created", 201, responseData);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listBusinessPurposes(tenantId);

        auto list = Json.emptyArray;
        foreach (bp; items) {
            list ~= Json.emptyObject
                .set("id", bp.id.value)
                .set("name", bp.name)
                .set("description", bp.description)
                .set("applicationGroupId", bp.applicationGroupId.value)
                .set("status", bp.status.to!string);
        }

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Business purposes retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = BusinessPurposeControllerId(
            precheck.id);
        if (id.isNull)
            return errorResponse("Invalid business purpose ID", 400);

        auto bp = usecase.getBusinessPurpose(tenantId, id);
        if (bp.isNull)
            return errorResponse("Business purpose not found", 404);

        auto response = Json.emptyObject
            .set("id", bp.id.value).set("name", bp.name)
            .set("description", bp.description)
            .set("applicationGroupId", bp.applicationGroupId.value)
            .set("dataSubjectRoleId", bp.dataSubjectRoleId.value)
            .set("legalEntityId", bp.legalEntityId.value)
            .set("status", bp.status.to!string)
            .set("referenceDate", bp.referenceDate);
        return successResponse("Business purpose retrieved successfully", "Retrieved", 200, response);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = BusinessPurposeControllerId(
            precheck.id);
        if (id.isNull)
            return errorResponse("Invalid business purpose ID", 400);

        auto data = precheck.data;
        UpdateBusinessPurposeRequest r;
        r.tenantId = tenantId;
        r.businessPurposeId = id;
        r.name = data
            .getString("name");
        r.description = data.getString("description");
        r.applicationGroupId = ApplicationGroupId(
            data.getString("applicationGroupId"));
        r.dataSubjectRoleId = DataSubjectRoleId(
            data.getString("dataSubjectRoleId"));
        r.legalEntityId = LegalEntityId(
            data.getString("legalEntityId"));
        r.referenceDate = data
            .getLong("referenceDate");

        auto result = usecase.updateBusinessPurpose(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto response = Json.emptyObject
            .set("id", result.id)
            .set("name", r.name)
            .set("description", r.description)
            .set("applicationGroupId", r.applicationGroupId.value)
            .set("dataSubjectRoleId", r.dataSubjectRoleId.value)
            .set("legalEntityId", r.legalEntityId.value)
            .set("referenceDate", r.referenceDate);

        return successResponse("Business purpose updated successfully", "Updated", 200, response);
    }

    protected Json activateHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;

        // path: /api/v1/data-retention/business-purposes/{id}/activate
        auto parts = path.split("/");
        string id = "";
        if (parts.length >= 6)
            id = parts[$ - 2];

        auto result = usecase.activateBusinessPurpose(
            BusinessPurposeControllerId(id));
        if (result.hasError)
            return errorResponse(
                result.message, 400);

        auto response = Json.emptyObject
            .set("id", result.id)
            .set("status", "active")
            .set("message", "Business purpose activated");

        return successResponse(
            "Business purpose activated successfully", "Activated", 200, response);
    }

    protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto result = activateHandler(req);
            res.writeJsonBody(response, result.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = BusinessPurposeControllerId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid business purpose ID", 400);

        auto result = usecase.deleteBusinessPurpose(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto response = Json.emptyObject.set("id", result.id);
        return successResponse("Business purpose deleted successfully", "Deleted", 200, response);
    }
}
