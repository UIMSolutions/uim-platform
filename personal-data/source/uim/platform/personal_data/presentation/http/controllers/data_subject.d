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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            CreateDataSubjectRequest r;
            r.tenantId = tenantId;
            r.id = precheck.id;
            r.subjectType = data.getString("subjectType");
            r.firstName = data.getString("firstName");
            r.lastName = data.getString("lastName");
            r.email = data.getString("email");
            r.phone = data.getString("phone");
            r.dateOfBirth = data.getString("dateOfBirth");
            r.organizationName = data.getString("organizationName");
            r.organizationId = data.getString("organizationId");
            r.externalId = data.getString("externalId");
            r.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.create(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto subjects = usecase.listDataSubjects(tenantId);

            auto jarr = subjects.map!(s => s.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", subjects.length)
                .set("resources", list);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
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
                .set("resources", list);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            if (path.length > 6 && path[$ - 6 .. $] == "/block")
                return;
            if (path.length > 6 && path[$ - 6 .. $] == "/erase")
                return;

            auto id = DataSubjectId(precheck.id);
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

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            UpdateDataSubjectRequest request;
            request.tenantId = tenantId;
            request.id = DataSubjectId(precheck.id);
            request.firstName = data.getString("firstName");
            request.lastName = data.getString("lastName");
            request.email = data.getString("email");
            request.phone = data.getString("phone");
            request.dateOfBirth = data.getString("dateOfBirth");
            request.organizationName = data.getString("organizationName");
            request.organizationId = data.getString("organizationId");
            request.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateDataSubject(request);
            if (result.hasError)
            return errorResponse(result.message, 400);
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
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 6]; // remove "/block"
            auto id = DataSubjectId(extractIdFromPath(stripped));

            auto result = usecase.block(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
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
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 6]; // remove "/erase"
            auto id = DataSubjectId(extractIdFromPath(stripped));

            auto result = usecase.eraseDataSubject(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
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

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = DataSubjectId(precheck.id);
            auto result = usecase.deleteDataSubject(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
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
