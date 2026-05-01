module uim.platform.data_retention.presentation.http.controllers.residence_rule;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ResidenceRuleController : PlatformController {
    private ManageResidenceRulesUseCase uc;

    this(ManageResidenceRulesUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/data-retention/residence-rules", &handleCreate);
        router.get("/api/v1/data-retention/residence-rules", &handleList);
        router.get("/api/v1/data-retention/residence-rules/*", &handleGet);
        router.put("/api/v1/data-retention/residence-rules/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/residence-rules/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateResidenceRuleRequest r;
            r.tenantId = req.getTenantId;
            r.businessPurposeId = j.getString("businessPurposeId");
            r.legalGroundId = j.getString("legalGroundId");
            r.duration = jsonInt(j, "duration");
            r.periodUnit = j.getString("periodUnit");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else { writeError(res, 400, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = uc.list(tenantId);
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
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto rr = uc.getById(id);
            if (rr.isNull) { writeError(res, 404, "Residence rule not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", rr.id.value)
                .set("businessPurposeId", rr.businessPurposeId.value)
                .set("legalGroundId", rr.legalGroundId.value)
                .set("duration", rr.duration)
                .set("periodUnit", rr.periodUnit.to!string)
                .set("isActive", rr.isActive), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateResidenceRuleRequest r;
            r.duration = jsonInt(j, "duration");
            r.periodUnit = j.getString("periodUnit");
            r.isActive = j.getBoolean("isActive", true);

            auto result = uc.update(id, r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 400, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            uc.removeById(id);
            res.writeJsonBody(Json.emptyObject, 204);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
