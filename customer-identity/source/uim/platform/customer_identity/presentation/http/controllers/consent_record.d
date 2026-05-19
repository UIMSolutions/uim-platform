/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.presentation.http.controllers.consent_record;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class ConsentRecordController : PlatformController {
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
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto items = consentRecords.listConsentRecords(tenantId);
        auto jarr = items.map!(e => e.toJson()).array.toJson;

        return Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr)
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto j = req.json;

        ConsentRecordDTO dto;
        dto.tenantId = tenantId;
        dto.customerId = CustomerId(j.getString("customerId"));
        dto.consentType = j.getString("consentType");
        dto.purpose = j.getString("purpose");
        dto.legalBasis = j.getString("legalBasis");
        dto.granted = j.getBool("granted");
        dto.ipAddress = j.getString("ipAddress");
        dto.userAgent = j.getString("userAgent");
        dto.version_ = j.getString("version");
        dto.locale = j.getString("locale");
        dto.createdBy = UserId(j.getString("createdBy"));

        auto result = consentRecords.grantConsent(dto);
        if (result.success)
            return Json.emptyObject.set("id", result.id).set("message", "Consent recorded").set("status", "success").set("statusCode", 201);
        return Json.emptyObject.set("error", result.error).set("status", "error").set("statusCode", 400);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto path = req.requestURI.to!string;
        auto id = ConsentRecordId(extractIdFromPath(path));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Consent Record ID").set("status", "error").set("statusCode", 400);

        auto e = consentRecords.getConsentRecord(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Consent record not found").set("status", "error").set("statusCode", 404);

        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto path = req.requestURI.to!string;
        auto id = ConsentRecordId(extractIdFromPath(path));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Consent Record ID").set("status", "error").set("statusCode", 400);

        auto result = consentRecords.revokeConsent(tenantId, id);
        if (result.success)
            return Json.emptyObject.set("id", result.id).set("message", "Consent revoked").set("status", "success").set("statusCode", 200);
        return Json.emptyObject.set("error", result.error).set("status", "error").set("statusCode", 400);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto path = req.requestURI.to!string;
        auto id = ConsentRecordId(extractIdFromPath(path));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Consent Record ID").set("status", "error").set("statusCode", 400);

        auto result = consentRecords.deleteConsentRecord(tenantId, id);
        if (result.success)
            return Json.emptyObject.set("message", "Consent record deleted").set("status", "success").set("statusCode", 200);
        return Json.emptyObject.set("error", result.error).set("status", "error").set("statusCode", 404);
    }
}
