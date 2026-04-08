/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.data_subject;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class DataSubjectController : SAPController {
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
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Data subject created");
                res.writeJsonBody(resp, 201);
            } ) {
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

            auto jarr = Json.emptyArray;
            foreach (ref s; subjects) {
                jarr ~= subjectToJson(s);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) subjects.length);
            resp["resources"] = jarr;
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
                if (s.id.length > 0) results ~= s;
            } ) {
                results = uc.search(firstName, lastName);
            }

            auto jarr = Json.emptyArray;
            foreach (ref s; results) {
                jarr ~= subjectToJson(s);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) results.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            if (path.length > 6 && path[$ - 6 .. $] == "/block") return;
            if (path.length > 6 && path[$ - 6 .. $] == "/erase") return;

            auto id = extractIdFromPath(path);
            auto s = uc.get_(id);
            if (s.id.isEmpty) {
                writeError(res, 404, "Data subject not found");
                return;
            }
            res.writeJsonBody(subjectToJson(s), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateDataSubjectRequest r;
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.firstName = j.getString("firstName");
            r.lastName = j.getString("lastName");
            r.email = j.getString("email");
            r.phone = j.getString("phone");
            r.dateOfBirth = j.getString("dateOfBirth");
            r.organizationName = j.getString("organizationName");
            r.organizationId = j.getString("organizationId");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Data subject updated");
                res.writeJsonBody(resp, 200);
            } ) {
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
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Data subject blocked");
                res.writeJsonBody(resp, 200);
            } ) {
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
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Data subject erased (anonymized)");
                res.writeJsonBody(resp, 200);
            } ) {
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
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Data subject deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json subjectToJson(ref DataSubject s) {
        auto j = Json.emptyObject;
        j["id"] = Json(s.id);
        j["subjectType"] = Json(s.subjectType.to!string);
        j["status"] = Json(s.status.to!string);
        j["firstName"] = Json(s.firstName);
        j["lastName"] = Json(s.lastName);
        j["email"] = Json(s.email);
        j["phone"] = Json(s.phone);
        j["dateOfBirth"] = Json(s.dateOfBirth);
        j["organizationName"] = Json(s.organizationName);
        j["organizationId"] = Json(s.organizationId);
        j["externalId"] = Json(s.externalId);
        j["createdBy"] = Json(s.createdBy);
        j["createdAt"] = Json(s.createdAt);
        return j;
    }
}
