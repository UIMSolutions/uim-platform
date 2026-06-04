/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.consent_record;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ConsentRecordController : ManageHttpController {
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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateConsentRecordRequest r;
        r.tenantId = precheck.tenantId;
        r.dataSubjectId = data.getString("dataSubjectId");
        r.purposeId = data.getString("purposeId");
        r.consentText = data.getString("consentText");
        r.consentVersion = data.getString("consentVersion");
        r.expiresAt = data.getLong("expiresAt");
        r.ipAddress = data.getString("ipAddress");
        r.userAgent = data.getString("userAgent");
        r.source = data.getString("source");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.create(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Consent record created successfully", "Created", 201, resp);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto params = req.queryParams();
        auto dataSubjectId = params.get("dataSubjectId", "");

        ConsentRecord[] consents = dataSubjectId.isEmpty
            ? usecase.listConsentRecords(
                tenantId) : usecase.listConsentRecords(tenantId, dataSubjectId);

        auto jarr = consents.map!(c => c.toJson).array.toJson;

        auto response = Json.emptyObject
            .set("count", consents.length)
            .set("resources", jarr);

        return successResponse("Consent records retrieved successfully", "Retrieved", 200, response);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        if (path.length > 9 && path[$ - 9 .. $] == "/withdraw")
            return;

        auto id = ConsentRecordId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid consent record ID", 400);

        auto consent = usecase.getConsentRecord(tenantId, id);
        if (consent.isNull)
            return errorResponse("Consent record not found", 404);

        return successResponse("Consent record retrieved successfully", "Retrieved", 200, consent
                .toJson);
    }

    protected void handleWithdraw(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto path = precheck.path;
            auto stripped = path[0 .. $ - 9]; // remove "/withdraw"
            auto id = ConsentRecordId(extractIdFromPath(stripped));

            auto data = precheck.data;
            WithdrawConsentRequest r;
            r.id = id;
            r.reason = data.getString("reason");
            r.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.withdraw(r);
            if (result.hasError)
                return errorResponse(result.message, 400);
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

override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConsentRecordId(precheck.id);

    auto result = usecase.deleteConsentRecord(tenantId, id);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Consent record deleted successfully", "Deleted", 200, resp);}
}
}
