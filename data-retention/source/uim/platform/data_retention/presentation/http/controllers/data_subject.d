module uim.platform.data_retention.presentation.http.controllers.data_subject;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class DataSubjectController : ManageController {
    private ManageDataSubjectsUseCase usecase;

    this(ManageDataSubjectsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/data-retention/data-subjects", &handleCreate);
        router.get("/api/v1/data-retention/data-subjects", &handleList);
        router.get("/api/v1/data-retention/data-subjects/*", &handleGet);
        router.put("/api/v1/data-retention/data-subjects/*", &handleUpdate);
        router.post("/api/v1/data-retention/data-subjects/*/block", &handleBlock);
        router.delete_("/api/v1/data-retention/data-subjects/*", &handleDelete);
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;

            CreateDataSubjectRequest r;
            r.tenantId = tenantId;
            r.roleId = RoleId(data.getString("roleId"));
            r.applicationGroupId = ApplicationGroupId(data.getString("applicationGroupId"));
            r.externalId = data.getString("externalId");
            r.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createDataSubject(r);
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


            auto items = usecase.listDataSubjects(tenantId);
            auto jarr = Json.emptyArray;
            foreach (ds; items) {
                jarr ~= Json.emptyObject
                    .set("id", ds.id.value).set("externalId", ds.externalId)
                    .set("roleId", ds.roleId.value)
                    .set("applicationGroupId", ds.applicationGroupId.value)
                    .set("lifecycleStatus", ds.lifecycleStatus.to!string);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr)
                    .set("totalCount", items.length), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = precheck.id;

            auto ds = usecase.getDataSubject(tenantId, id);
            if (ds.isNull) {
                writeError(res, 404, "Data subject not found");
                return;
            }

            auto response = Json.emptyObject
                .set("id", ds.id.value).set("externalId", ds.externalId)
                .set("roleId", ds.roleId.value)
                .set("applicationGroupId", ds.applicationGroupId.value)
                .set("lifecycleStatus", ds.lifecycleStatus.to!string)
                .set("endOfPurposeDate", ds.endOfPurposeDate)
                .set("endOfRetentionDate", ds.endOfRetentionDate);

            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = DataSubjectprecheck.id);

            auto data = precheck.data;
            UpdateDataSubjectRequest r;
            r.tenantId = tenantId;
            r.lifecycleStatus = data.getString("lifecycleStatus");
            r.roleId = RoleId(data.getString("roleId"));

            auto result = usecase.updateDataSubject(id, r);
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

    protected void handleBlock(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto parts = path.split("/");
            string id = "";
            if (parts.length >= 6)
                id = parts[$ - 2];
            auto id = DataSubjectId(id);

            auto result = usecase.blockDataSubject(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("lifecycleStatus", "blocked")
                    .set("message", "Data subject has been blocked");

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
            auto tenantId = precheck.tenantId;
            auto id = DataSubjectprecheck.id);

            usecase.deleteDataSubject(tenantId, id);
            res.writeJsonBody(Json.emptyObject, 204);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
