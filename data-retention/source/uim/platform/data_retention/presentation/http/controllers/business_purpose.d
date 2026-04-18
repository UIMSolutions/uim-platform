module uim.platform.data_retention.presentation.http.controllers.business_purpose;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class BusinessPurposeController : PlatformController {
    private ManageBusinessPurposesUseCase uc;

    this(ManageBusinessPurposesUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/data-retention/business-purposes", &handleCreate);
        router.get("/api/v1/data-retention/business-purposes", &handleList);
        router.get("/api/v1/data-retention/business-purposes/*", &handleGet);
        router.put("/api/v1/data-retention/business-purposes/*", &handleUpdate);
        router.post("/api/v1/data-retention/business-purposes/*/activate", &handleActivate);
        router.delete_("/api/v1/data-retention/business-purposes/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateBusinessPurposeRequest r;
            r.tenantId = req.getTenantId;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.applicationGroupId = j.getString("applicationGroupId");
            r.dataSubjectRoleId = j.getString("dataSubjectRoleId");
            r.legalEntityId = j.getString("legalEntityId");
            r.referenceDate = jsonLong(j, "referenceDate");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = uc.list(tenantId);
            auto jarr = Json.emptyArray;
            foreach (bp; items) {
                jarr ~= Json.emptyObject
                    .set("id", bp.id.value).set("name", bp.name)
                    .set("description", bp.description)
                    .set("applicationGroupId", bp.applicationGroupId.value)
                    .set("status", bp.status.to!string);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto bp = uc.getById(id);
            if (bp.id.isEmpty) { writeError(res, 404, "Business purpose not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", bp.id.value).set("name", bp.name)
                .set("description", bp.description)
                .set("applicationGroupId", bp.applicationGroupId.value)
                .set("dataSubjectRoleId", bp.dataSubjectRoleId.value)
                .set("legalEntityId", bp.legalEntityId.value)
                .set("status", bp.status.to!string)
                .set("referenceDate", bp.referenceDate), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateBusinessPurposeRequest r;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.applicationGroupId = j.getString("applicationGroupId");
            r.dataSubjectRoleId = j.getString("dataSubjectRoleId");
            r.legalEntityId = j.getString("legalEntityId");
            r.referenceDate = jsonLong(j, "referenceDate");

            auto result = uc.update(id, r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 400, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            // path: /api/v1/data-retention/business-purposes/{id}/activate
            auto parts = path.split("/");
            string id = "";
            if (parts.length >= 6) id = parts[$ - 2];

            auto result = uc.activate(id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("status", "active"), 200);
            } else { writeError(res, 400, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else { writeError(res, 400, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
