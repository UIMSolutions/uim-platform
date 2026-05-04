/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.consent_record;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ConsentRecordController : PlatformController {
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
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Consent record created");

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
            auto params = req.queryParams();
            auto dataSubjectId = params.get("dataSubjectId", "");

            ConsentRecord[] consents;
            if (dataSubjectId.length > 0) {
                consents = uc.listConsentRecordsByDataSubject(dataSubjectId);
            } else {
                consents = uc.listConsentRecordsByTenant(tenantId);
            }

            auto jarr = consents.map!(c => c.toJson).array.toJson;

            auto response = Json.emptyObject
                .set("count", consents.length)
                .set("resources", jarr);

            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            if (path.length > 9 && path[$ - 9 .. $] == "/withdraw")
                return;

            auto id = extractIdFromPath(path);
            if (!uc.hasConsentRecord(id)) {
                writeError(res, 404, "Consent record not found");
                return;
            }

            auto consent = uc.getConsentRecord(id);
            res.writeJsonBody(consent.toJson, 200);
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
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = uc.withdraw(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Consent withdrawn");

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
                    .set("message", "Consent record deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
