module uim.platform.data_retention.presentation.http.controllers.data_subject;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class DataSubjectController : PlatformController {
    private ManageDataSubjectsUseCase uc;

    this(ManageDataSubjectsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/data-retention/data-subjects", &handleCreate);
        router.get("/api/v1/data-retention/data-subjects", &handleList);
        router.get("/api/v1/data-retention/data-subjects/*", &handleGet);
        router.put("/api/v1/data-retention/data-subjects/*", &handleUpdate);
        router.post("/api/v1/data-retention/data-subjects/*/block", &handleBlock);
        router.delete_("/api/v1/data-retention/data-subjects/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateDataSubjectRequest r;
            r.tenantId = req.getTenantId;
            r.roleId = j.getString("roleId");
            r.applicationGroupId = j.getString("applicationGroupId");
            r.externalId = j.getString("externalId");
            r.createdBy = UserId(j.getString("createdBy"));

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
            foreach (ds; items) {
                jarr ~= Json.emptyObject
                    .set("id", ds.id.value).set("externalId", ds.externalId)
                    .set("roleId", ds.roleId.value)
                    .set("applicationGroupId", ds.applicationGroupId.value)
                    .set("lifecycleStatus", ds.lifecycleStatus.to!string);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto ds = uc.getById(id);
            if (ds.isNull) { writeError(res, 404, "Data subject not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", ds.id.value).set("externalId", ds.externalId)
                .set("roleId", ds.roleId.value)
                .set("applicationGroupId", ds.applicationGroupId.value)
                .set("lifecycleStatus", ds.lifecycleStatus.to!string)
                .set("endOfPurposeDate", ds.endOfPurposeDate)
                .set("endOfRetentionDate", ds.endOfRetentionDate), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateDataSubjectRequest r;
            r.lifecycleStatus = j.getString("lifecycleStatus");
            r.roleId = j.getString("roleId");

            auto result = uc.update(id, r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 400, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleBlock(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto parts = path.split("/");
            string id = "";
            if (parts.length >= 6) id = parts[$ - 2];

            auto result = uc.block(id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("lifecycleStatus", "blocked"), 200);
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
