module uim.platform.data_retention.presentation.http.controllers.legal_entity;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class LegalEntityController : PlatformController {
    private ManageLegalEntitiesUseCase uc;

    this(ManageLegalEntitiesUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/data-retention/legal-entities", &handleCreate);
        router.get("/api/v1/data-retention/legal-entities", &handleList);
        router.get("/api/v1/data-retention/legal-entities/*", &handleGet);
        router.put("/api/v1/data-retention/legal-entities/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/legal-entities/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateLegalEntityRequest r;
            r.tenantId = req.getTenantId;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.country = j.getString("country");
            r.region = j.getString("region");
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
            foreach (le; items) {
                jarr ~= Json.emptyObject
                    .set("id", le.id.value).set("name", le.name)
                    .set("description", le.description)
                    .set("country", le.country)
                    .set("isActive", le.isActive);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto le = uc.getById(id);
            if (le.isNull) { writeError(res, 404, "Legal entity not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", le.id.value).set("name", le.name)
                .set("description", le.description)
                .set("country", le.country).set("region", le.region)
                .set("isActive", le.isActive), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateLegalEntityRequest r;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.country = j.getString("country");
            r.region = j.getString("region");
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
            uc.remove(id);
            res.writeJsonBody(Json.emptyObject, 204);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
