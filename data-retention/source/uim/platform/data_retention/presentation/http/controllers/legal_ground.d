module uim.platform.data_retention.presentation.http.controllers.legal_ground;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class LegalGroundController : ManageController {
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

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
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

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = LegalGroundprecheck.id);
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

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = LegalGroundprecheck.id);
            auto j = req.json;

            UpdateLegalGroundRequest r;
            r.tenantId = tenantId;
            r.legalGroundId = id;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.type = j.getString("type");
            r.referenceDate = jsonLong(j, "referenceDate");

            auto result = usecase.updateLegalGround(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Legal ground updated successfully");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = LegalGroundprecheck.id);

            usecase.deleteLegalGround(tenantId, id);
            res.writeJsonBody(Json.emptyObject, 204);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
