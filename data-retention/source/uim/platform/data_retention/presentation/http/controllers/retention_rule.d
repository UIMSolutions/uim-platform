module uim.platform.data_retention.presentation.http.controllers.retention_rule;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class RetentionRuleController : ManageController {
    private ManageRetentionRulesUseCase usecase;

    this(ManageRetentionRulesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/data-retention/retention-rules", &handleCreate);
        router.get("/api/v1/data-retention/retention-rules", &handleList);
        router.get("/api/v1/data-retention/retention-rules/*", &handleGet);
        router.put("/api/v1/data-retention/retention-rules/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/retention-rules/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            CreateRetentionRuleRequest r;
            r.tenantId = tenantId;
            r.businessPurposeId = data.getString("businessPurposeId");
            r.legalGroundId = data.getString("legalGroundId");
            r.duration = jsonInt(j, "duration");
            r.periodUnit = data.getString("periodUnit");
            r.actionOnExpiry = data.getString("actionOnExpiry");
            r.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createRetentionRule(r);
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


            auto items = usecase.listRetentionRules(tenantId);
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

            auto resp = Json.emptyObject
                .set("items", jarr)
                .set("totalCount", items.length)
                .set("message", "Retention rules retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = precheck.id;
            auto rr = usecase.getRetentionRule(tenantId, id);
            if (rr.isNull) {
                writeError(res, 404, "Retention rule not found");
                return;
            }
            res.writeJsonBody(Json.emptyObject
                    .set("id", rr.id.value)
                    .set("businessPurposeId", rr.businessPurposeId.value)
                    .set("legalGroundId", rr.legalGroundId.value)
                    .set("duration", rr.duration)
                    .set("periodUnit", rr.periodUnit.to!string)
                    .set("actionOnExpiry", rr.actionOnExpiry.to!string)
                    .set("isActive", rr.isActive), 200);

        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = RetentionRuleId(precheck.id);
            auto data = precheck.data;
            UpdateRetentionRuleRequest r;
            r.retentionRuleId = id;
            r.tenantId = tenantId;
            r.duration = jsonInt(j, "duration");
            r.periodUnit = data.getString("periodUnit");
            r.actionOnExpiry = data.getString("actionOnExpiry");
            r.isActive = data.getBoolean("isActive", true);

            auto result = usecase.updateRetentionRule(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = RetentionRuleId(precheck.id);
            
            usecase.deleteRetentionRule(tenantId, id);
            res.writeJsonBody(Json.emptyObject, 204);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
