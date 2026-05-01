module uim.platform.data_retention.presentation.http.controllers.legal_ground;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class LegalGroundController : PlatformController {
    private ManageLegalGroundsUseCase uc;

    this(ManageLegalGroundsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/data-retention/legal-grounds", &handleCreate);
        router.get("/api/v1/data-retention/legal-grounds", &handleList);
        router.get("/api/v1/data-retention/legal-grounds/*", &handleGet);
        router.put("/api/v1/data-retention/legal-grounds/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/legal-grounds/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateLegalGroundRequest r;
            r.tenantId = req.getTenantId;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.businessPurposeId = j.getString("businessPurposeId");
            r.type = j.getString("type");
            r.referenceDate = jsonLong(j, "referenceDate");
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
            foreach (lg; items) {
                jarr ~= Json.emptyObject
                    .set("id", lg.id.value).set("name", lg.name)
                    .set("description", lg.description)
                    .set("businessPurposeId", lg.businessPurposeId.value)
                    .set("type", lg.type.to!string);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto lg = uc.getById(id);
            if (lg.isNull) { writeError(res, 404, "Legal ground not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", lg.id.value).set("name", lg.name)
                .set("description", lg.description)
                .set("businessPurposeId", lg.businessPurposeId.value)
                .set("type", lg.type.to!string)
                .set("referenceDate", lg.referenceDate)
                .set("isActive", lg.isActive), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateLegalGroundRequest r;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.type = j.getString("type");
            r.referenceDate = jsonLong(j, "referenceDate");

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
