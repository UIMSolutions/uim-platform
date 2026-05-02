/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.data_subject;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class DataSubjectController : PlatformController {
    private ManageDataSubjectsUseCase uc;

    this(ManageDataSubjectsUseCase uc) {
        this.uc = uc;
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

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateDataSubjectRequest r;
            r.tenantId = req.getTenantId;
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
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Data subject created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            TenantId tenantId = req.getTenantId;
            auto subjects = uc.list(tenantId);

            auto jarr = subjects.map!(s => s.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", subjects.length)
                .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto params = req.queryParams();
            auto firstName = params.get("firstName", "");
            auto lastName = params.get("lastName", "");
            auto email = params.get("email", "");

            DataSubject[] results;
            if (email.length > 0) {
                auto s = uc.findByEmail(email);
                if (s.id.length > 0)
                    results ~= s;
            } else {
                results = uc.search(firstName, lastName);
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

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            if (path.length > 6 && path[$ - 6 .. $] == "/block")
                return;
            if (path.length > 6 && path[$ - 6 .. $] == "/erase")
                return;

            auto id = extractIdFromPath(path);
            if (!uc.hasDataSubject(id)) {
                writeError(res, 404, "Data subject not found");
                return;
            }

            auto subject = uc.getDataSubject(id);
            res.writeJsonBody(subject.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateDataSubjectRequest request;
            request.tenantId = req.getTenantId;
            request.id = extractIdFromPath(req.requestURI.to!string);
            request.firstName = j.getString("firstName");
            request.lastName = j.getString("lastName");
            request.email = j.getString("email");
            request.phone = j.getString("phone");
            request.dateOfBirth = j.getString("dateOfBirth");
            request.organizationName = j.getString("organizationName");
            request.organizationId = j.getString("organizationId");
            request.updatedBy = j.getString("updatedBy");

            auto result = uc.updateDataSubject(request);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Data subject updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleBlock(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 6]; // remove "/block"
            auto id = extractIdFromPath(stripped);

            auto result = uc.block(id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Data subject blocked");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleErase(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 6]; // remove "/erase"
            auto id = extractIdFromPath(stripped);

            auto result = uc.erase(id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Data subject erased (anonymized)");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.removeById(id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Data subject deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
