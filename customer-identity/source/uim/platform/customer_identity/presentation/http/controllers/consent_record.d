/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.presentation.http.controllers.consent_record;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class ConsentRecordController : ManageHttpController {
    private ManageConsentRecordsUseCase consentRecords;

    this(ManageConsentRecordsUseCase consentRecords) {
        this.consentRecords = consentRecords;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/customer-identity/consents", &handleList);
        router.get("/api/v1/customer-identity/consents/*", &handleGet);
        router.post("/api/v1/customer-identity/consents", &handleCreate);
        router.put("/api/v1/customer-identity/consents/*", &handleUpdate);
        router.delete_("/api/v1/customer-identity/consents/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = consentRecords.listConsentRecords(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Consent records retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ConsentRecordDTO dto;
        dto.tenantId = tenantId;
        dto.customerId = CustomerId(data.getString("customerId"));
        dto.consentType = data.getString("consentType");
        dto.purpose = data.getString("purpose");
        dto.legalBasis = data.getString("legalBasis");
        dto.granted = data.getBoolean("granted");
        dto.ipAddress = data.getString("ipAddress");
        dto.userAgent = data.getString("userAgent");
        dto.version_ = data.getString("version");
        dto.locale = data.getString("locale");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = consentRecords.grantConsent(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Consent recorded successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ConsentRecordId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Consent Record ID", 400);

        auto e = consentRecords.getConsentRecord(tenantId, id);
        if (e.isNull)
            return errorResponse("Consent record not found", 404);

        return successResponse("Consent record retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ConsentRecordId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Consent Record ID", 400);

        auto result = consentRecords.revokeConsent(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Consent revoked successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ConsentRecordId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Consent Record ID", 400);

        auto result = consentRecords.deleteConsentRecord(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Consent record deleted successfully", "Deleted", 200, responseData);
    }
}
