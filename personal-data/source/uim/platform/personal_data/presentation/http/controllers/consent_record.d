/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.consent_record;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ConsentRecordController : ManageController {
    private ManageConsentRecordsUseCase usecase;

    this(ManageConsentRecordsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/personal-data/consents", &handleList);
        router.get("/api/v1/personal-data/consents/*", &handleGet);
        router.post("/api/v1/personal-data/consents", &handleCreate);
        router.post("/api/v1/personal-data/consents/*/withdraw", &handleWithdraw);
        router.delete_("/api/v1/personal-data/consents/*", &handleDelete);
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CreateConsentRecordRequest r;
            r.tenantId = tenantId;
            r.dataSubjectId = j.getString("dataSubjectId");
            r.purposeId = j.getString("purposeId");
            r.consentText = j.getString("consentText");
            r.consentVersion = j.getString("consentVersion");
            r.expiresAt = j.getLong("expiresAt");
            r.ipAddress = j.getString("ipAddress");
            r.userAgent = j.getString("userAgent");
            r.source = j.getString("source");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Consent record created");

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
            auto params = req.queryParams();
            auto dataSubjectId = params.get("dataSubjectId", "");

            ConsentRecord[] consents = dataSubjectId.isEmpty
                ? usecase.listConsentRecords(tenantId) : usecase.listConsentRecords(tenantId, dataSubjectId);

            auto jarr = consents.map!(c => c.toJson).array.toJson;

            auto response = Json.emptyObject
                .set("count", consents.length)
                .set("resources", jarr)
                .set("message", "Consent records retrieved successfully");

            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            if (path.length > 9 && path[$ - 9 .. $] == "/withdraw")
                return;

            auto id = ConsentRecordId(extractIdFromPath(path));
            if (!usecase.hasConsentRecord(tenantId, id)) {
                writeError(res, 404, "Consent record not found");
                return;
            }

            auto consent = usecase.getConsentRecord(tenantId, id);
            res.writeJsonBody(consent.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleWithdraw(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 9]; // remove "/withdraw"
            auto id = ConsentRecordId(extractIdFromPath(stripped));

            auto j = req.json;
            WithdrawConsentRequest r;
            r.id = id;
            r.reason = j.getString("reason");
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.withdraw(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Consent withdrawn");

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
            auto id = ConsentRecordId(extractIdFromPath(req.requestURI.to!string));

            auto result = usecase.deleteConsentRecord(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Consent record deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
