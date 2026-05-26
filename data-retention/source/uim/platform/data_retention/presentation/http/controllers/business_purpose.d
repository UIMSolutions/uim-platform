module uim.platform.data_retention.presentation.http.controllers.business_purpose;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class BusinessPurposeController : ManageController {
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

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreateBusinessPurposeRequest r;
            r.tenantId = tenantId;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.applicationGroupId = ApplicationGroupId(j.getString("applicationGroupId"));
            r.dataSubjectRoleId = DataSubjectRoleId(j.getString("dataSubjectRoleId"));
            r.legalEntityId = LegalEntityId(j.getString("legalEntityId"));
            r.referenceDate = jsonLong(j, "referenceDate");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createBusinessPurpose(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;


            auto items = usecase.listBusinessPurposes(tenantId);
            auto jarr = Json.emptyArray;
            foreach (bp; items) {
                jarr ~= Json.emptyObject
                    .set("id", bp.id.value)
                    .set("name", bp.name)
                    .set("description", bp.description)
                    .set("applicationGroupId", bp.applicationGroupId.value)
                    .set("status", bp.status.to!string);
            }

            auto response = Json.emptyObject
                .set("items", jarr)
                .set("totalCount", items.length);

            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = BusinessPurposeControllerprecheck.id);

            auto bp = usecase.getBusinessPurpose(tenantId, id);
            if (bp.isNull) {
                writeError(res, 404, "Business purpose not found");
                return;
            }
            res.writeJsonBody(Json.emptyObject
                    .set("id", bp.id.value).set("name", bp.name)
                    .set("description", bp.description)
                    .set("applicationGroupId", bp.applicationGroupId.value)
                    .set("dataSubjectRoleId", bp.dataSubjectRoleId.value)
                    .set("legalEntityId", bp.legalEntityId.value)
                    .set("status", bp.status.to!string)
                    .set("referenceDate", bp.referenceDate), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = BusinessPurposeControllerprecheck.id);

            auto j = req.json;
            UpdateBusinessPurposeRequest r;
            r.tenantId = tenantId;
            r.businessPurposeId = id;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.applicationGroupId = ApplicationGroupId(j.getString("applicationGroupId"));
            r.dataSubjectRoleId = DataSubjectRoleId(j.getString("dataSubjectRoleId"));
            r.legalEntityId = LegalEntityId(j.getString("legalEntityId"));
            r.referenceDate = jsonLong(j, "referenceDate");

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
                    
                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto path = req.requestURI.to!string;
            // path: /api/v1/data-retention/business-purposes/{id}/activate
            auto parts = path.split("/");
            string id = "";
            if (parts.length >= 6)
                id = parts[$ - 2];

            auto result = usecase.activateBusinessPurpose(BusinessPurposeControllerId(id));
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("status", "active")
                    .set("message", "Business purpose activated");

                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = BusinessPurposeControllerprecheck.id);
            auto result = usecase.deleteBusinessPurpose(tenantId, id);

            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject, 204);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
