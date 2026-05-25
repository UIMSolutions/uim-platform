/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.data_subject;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class DataSubjectController : ManageController {
    private ManageDataSubjectsUseCase usecase;

    this(ManageDataSubjectsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/personal-data/subjects", &handleList);
        router.get("/api/v1/personal-data/subjects/search", &handleSearch);
        router.get("/api/v1/personal-data/subjects/*", &handleGet);
        router.post("/api/v1/personal-data/subjects", &handleCreate);
        router.put("/api/v1/personal-data/subjects/*", &handleUpdate);
        router.post("/api/v1/personal-data/subjects/*/block", &handleBlock);
        router.post("/api/v1/personal-data/subjects/*/erase", &handleErase);
        router.delete_("/api/v1/personal-data/subjects/*", &handleDelete);
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CreateDataSubjectRequest r;
            r.tenantId = tenantId;
            r.id = j.getString("id");
            r.subjectType = j.getString("subjectType");
            r.firstName = j.getString("firstName");
            r.lastName = j.getString("lastName");
            r.email = j.getString("email");
            r.phone = j.getString("phone");
            r.dateOfBirth = j.getString("dateOfBirth");
            r.organizationName = j.getString("organizationName");
            r.organizationId = j.getString("organizationId");
            r.externalId = j.getString("externalId");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data subject created");

                res.writeJsonBody(resp, 201);
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
            auto subjects = usecase.listDataSubjects(tenantId);

            auto jarr = subjects.map!(s => s.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", subjects.length)
                .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto params = req.queryParams();
            auto firstName = params.get("firstName", "");
            auto lastName = params.get("lastName", "");
            auto email = params.get("email", "");

            DataSubject[] results;
            if (!email.isEmpty) {
                auto s = usecase.findByEmail(email);
                if (!s.isNull)
                    results ~= s;
            } else {
                results = usecase.searchDataSubjects(tenantId, firstName, lastName);
            }

            auto jarr = results.map!(s => s.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", results.length)
                .set("resources", jarr);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            if (path.length > 6 && path[$ - 6 .. $] == "/block")
                return;
            if (path.length > 6 && path[$ - 6 .. $] == "/erase")
                return;

            auto id = DataSubjectId(extractIdFromPath(path));
            if (!usecase.hasDataSubject(tenantId, id)) {
                writeError(res, 404, "Data subject not found");
                return;
            }

            auto subject = usecase.getDataSubject(tenantId, id);
            res.writeJsonBody(subject.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            UpdateDataSubjectRequest request;
            request.tenantId = tenantId;
            request.id = DataSubjectId(extractIdFromPath(req.requestURI.to!string));
            request.firstName = j.getString("firstName");
            request.lastName = j.getString("lastName");
            request.email = j.getString("email");
            request.phone = j.getString("phone");
            request.dateOfBirth = j.getString("dateOfBirth");
            request.organizationName = j.getString("organizationName");
            request.organizationId = j.getString("organizationId");
            request.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateDataSubject(request);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data subject updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleBlock(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 6]; // remove "/block"
            auto id = DataSubjectId(extractIdFromPath(stripped));

            auto result = usecase.block(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data subject blocked");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleErase(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 6]; // remove "/erase"
            auto id = DataSubjectId(extractIdFromPath(stripped));

            auto result = usecase.eraseDataSubject(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data subject erased (anonymized)");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = DataSubjectId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteDataSubject(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Data subject deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
