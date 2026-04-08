/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.consent_record;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ConsentRecordController : SAPController {
    private ManageConsentRecordsUseCase uc;

    this(ManageConsentRecordsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/personal-data/consents", &handleList);
        router.get("/api/v1/personal-data/consents/*", &handleGet);
        router.post("/api/v1/personal-data/consents", &handleCreate);
        router.post("/api/v1/personal-data/consents/*/withdraw", &handleWithdraw);
        router.delete_("/api/v1/personal-data/consents/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateConsentRecordRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.dataSubjectId = j.getString("dataSubjectId");
            r.purposeId = j.getString("purposeId");
            r.consentText = j.getString("consentText");
            r.consentVersion = j.getString("consentVersion");
            r.expiresAt = j.getString("expiresAt");
            r.ipAddress = j.getString("ipAddress");
            r.userAgent = j.getString("userAgent");
            r.source = j.getString("source");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Consent record created");
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
            auto tenantId = req.getTenantId;
            auto params = req.queryParams();
            auto dataSubjectId = params.get("dataSubjectId", "");

            ConsentRecord[] consents;
            if (dataSubjectId.length > 0) {
                consents = uc.listByDataSubject(dataSubjectId);
            } ) {
                consents = uc.list(tenantId);
            }

            auto jarr = Json.emptyArray;
            foreach (ref c; consents) {
                jarr ~= consentToJson(c);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) consents.length);
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
            if (path.length > 9 && path[$ - 9 .. $] == "/withdraw") return;

            auto id = extractIdFromPath(path);
            auto c = uc.get_(id);
            if (c.id.length == 0) {
                writeError(res, 404, "Consent record not found");
                return;
            }
            res.writeJsonBody(consentToJson(c), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleWithdraw(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 9]; // remove "/withdraw"
            auto id = extractIdFromPath(stripped);

            auto j = req.json;
            WithdrawConsentRequest r;
            r.id = id;
            r.reason = j.getString("reason");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.withdraw(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Consent withdrawn");
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
                resp["message"] = Json("Consent record deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json consentToJson(ref ConsentRecord c) {
        auto j = Json.emptyObject;
        j["id"] = Json(c.id);
        j["dataSubjectId"] = Json(c.dataSubjectId);
        j["purposeId"] = Json(c.purposeId);
        j["status"] = Json(c.status.to!string);
        j["consentText"] = Json(c.consentText);
        j["consentVersion"] = Json(c.consentVersion);
        j["givenAt"] = Json(c.givenAt);
        j["withdrawnAt"] = Json(c.withdrawnAt);
        j["expiresAt"] = Json(c.expiresAt);
        j["source"] = Json(c.source);
        j["createdBy"] = Json(c.createdBy);
        j["createdAt"] = Json(c.createdAt);
        return j;
    }
}
