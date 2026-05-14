module uim.platform.data_retention.presentation.http.controllers.data_subject;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class DataSubjectController : PlatformController {
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

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreateDataSubjectRequest r;
            r.tenantId = tenantId;
            r.roleId = RoleId(j.getString("roleId"));
            r.applicationGroupId = ApplicationGroupId(j.getString("applicationGroupId"));
            r.externalId = j.getString("externalId");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createDataSubject(r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

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

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);

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

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = DataSubjectId(extractIdFromPath(req.requestURI.to!string));

            auto j = req.json;
            UpdateDataSubjectRequest r;
            r.tenantId = tenantId;
            r.lifecycleStatus = j.getString("lifecycleStatus");
            r.roleId = RoleId(j.getString("roleId"));

            auto result = usecase.updateDataSubject(id, r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetBlock(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto parts = path.split("/");
            string id = "";
            if (parts.length >= 6)
                id = parts[$ - 2];
            auto id = DataSubjectId(id);

            auto result = usecase.blockDataSubject(tenantId, id);
            if (result.success) {
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("lifecycleStatus", "blocked")
                    .set("message", "Data subject has been blocked");

                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = DataSubjectId(extractIdFromPath(req.requestURI.to!string));

            usecase.deleteDataSubject(tenantId, id);
            res.writeJsonBody(Json.emptyObject, 204);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
