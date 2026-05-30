module uim.platform.data_retention.presentation.http.controllers.legal_entity;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class LegalEntityController : ManageController {
    private ManageLegalEntitiesUseCase usecase;

    this(ManageLegalEntitiesUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.post("/api/v1/data-retention/legal-entities", &handleCreate);
        router.get("/api/v1/data-retention/legal-entities", &handleList);
        router.get("/api/v1/data-retention/legal-entities/*", &handleGet);
        router.put("/api/v1/data-retention/legal-entities/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/legal-entities/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            CreateLegalEntityRequest r;
            r.tenantId = tenantId;
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.country = data.getString("country");
            r.region = data.getString("region");
            r.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createLegalEntity(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            
            auto items = usecase.listLegalEntity(tenantId);
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

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = LegalEntityId(precheck.id);

            auto le = usecase.getLegalEntity(tenantId, id);
            if (le.isNull) { writeError(res, 404, "Legal entity not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", le.id.value).set("name", le.name)
                .set("description", le.description)
                .set("country", le.country).set("region", le.region)
                .set("isActive", le.isActive), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = LegalEntityId(precheck.id);
            auto data = precheck.data;
            UpdateLegalEntityRequest r;
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.country = data.getString("country");
            r.region = data.getString("region");
            r.isActive = data.getBoolean("isActive", true);

            auto result = usecase.updateLegalEntity(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = precheck.id;

            usecase.deleteLegalEntity(tenantId, id);
            res.writeJsonBody(Json.emptyObject, 204);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
