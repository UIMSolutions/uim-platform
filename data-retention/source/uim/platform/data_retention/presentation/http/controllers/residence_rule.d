module uim.platform.data_retention.presentation.http.controllers.residence_rule;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ResidenceRuleController : ManageController {
    private ManageResidenceRulesUseCase usecase;

    this(ManageResidenceRulesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/data-retention/residence-rules", &handleCreate);
        router.get("/api/v1/data-retention/residence-rules", &handleList);
        router.get("/api/v1/data-retention/residence-rules/*", &handleGet);
        router.put("/api/v1/data-retention/residence-rules/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/residence-rules/*", &handleDelete);
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreateResidenceRuleRequest r;
            r.tenantId = tenantId;
            r.businessPurposeId = BusinessPurposeId(j.getString("businessPurposeId"));
            r.legalGroundId = LegalGroundId(j.getString("legalGroundId"));
            r.duration = jsonInt(j, "duration");
            r.periodUnit = j.getString("periodUnit");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createResidenceRule(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("businessPurposeId", r.businessPurposeId.value)
                    .set("legalGroundId", r.legalGroundId.value)
                    .set("duration", r.duration)
                    .set("periodUnit", r.periodUnit)
                    .set("isActive", true);
                res.writeJsonBody(response, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto items = usecase.listResidenceRules(tenantId);
            auto jarr = Json.emptyArray;
            foreach (rr; items) {
                jarr ~= Json.emptyObject
                    .set("id", rr.id.value)
                    .set("businessPurposeId", rr.businessPurposeId.value)
                    .set("legalGroundId", rr.legalGroundId.value)
                    .set("duration", rr.duration)
                    .set("periodUnit", rr.periodUnit.to!string)
                    .set("isActive", rr.isActive);
            }

            auto response = Json.emptyObject
                .set("items", jarr)
                .set("totalCount", items.length)
                .set("message", "Residence rules retrieved");

            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = ResidenceRuleId(extractIdFromPath(req.requestURI.to!string));

            auto rr = usecase.getResidenceRule(tenantId, id);
            if (rr.isNull) {
                writeError(res, 404, "Residence rule not found");
                return;
            }
            res.writeJsonBody(Json.emptyObject
                    .set("id", rr.id.value)
                    .set("businessPurposeId", rr.businessPurposeId.value)
                    .set("legalGroundId", rr.legalGroundId.value)
                    .set("duration", rr.duration)
                    .set("periodUnit", rr.periodUnit.to!string)
                    .set("isActive", rr.isActive), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = ResidenceRuleId(extractIdFromPath(req.requestURI.to!string));

            auto j = req.json;
            UpdateResidenceRuleRequest r;
            r.duration = jsonInt(j, "duration");
            r.periodUnit = j.getString("periodUnit");
            r.isActive = j.getBoolean("isActive", true);

            auto result = usecase.updateResidenceRule(id, r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("duration", r.duration)
                    .set("periodUnit", r.periodUnit.to!string)
                    .set("isActive", r.isActive);

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
            auto id = ResidenceRuleId(extractIdFromPath(req.requestURI.to!string));
            usecase.deleteResidenceRule(id);
            res.writeJsonBody(Json.emptyObject, 204);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
