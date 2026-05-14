module uim.platform.data_retention.presentation.http.controllers.legal_ground;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class LegalGroundController : PlatformController {
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

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreateLegalGroundRequest r;
            r.tenantId = tenantId;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.businessPurposeId = BusinessPurposeId(j.getString("businessPurposeId"));
            r.type = j.getString("type");
            r.referenceDate = jsonLong(j, "referenceDate");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createLegalGround(r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto items = usecase.listLegalGrounds(tenantId);
            auto jarr = Json.emptyArray;
            foreach (lg; items) {
                jarr ~= Json.emptyObject
                    .set("id", lg.id.value).set("name", lg.name)
                    .set("description", lg.description)
                    .set("businessPurposeId", lg.businessPurposeId.value)
                    .set("type", lg.type.to!string);
            }

            auto resp = Json.emptyObject
                .set("items", jarr)
                .set("totalCount", items.length)
                .set("message", "Legal grounds retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = LegalGroundId(extractIdFromPath(req.requestURI.to!string));
            auto lg = usecase.getLegalGround(tenantId, id);
            if (lg.isNull) {
                writeError(res, 404, "Legal ground not found");
                return;
            }

            auto response = Json.emptyObject
                    .set("id", lg.id.value).set("name", lg.name)
                    .set("description", lg.description)
                    .set("businessPurposeId", lg.businessPurposeId.value)
                    .set("type", lg.type.to!string)
                    .set("referenceDate", lg.referenceDate)
                    .set("isActive", lg.isActive);

            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = LegalGroundId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;

            UpdateLegalGroundRequest r;
            r.tenantId = tenantId;
            r.legalGroundId = id;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.type = j.getString("type");
            r.referenceDate = jsonLong(j, "referenceDate");

            auto result = usecase.updateLegalGround(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Legal ground updated successfully");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = LegalGroundId(extractIdFromPath(req.requestURI.to!string));

            usecase.deleteLegalGround(tenantId, id);
            res.writeJsonBody(Json.emptyObject, 204);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
