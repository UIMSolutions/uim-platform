/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.trusted_certificate;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class TrustedCertificateController : ManageController {
    private ManageTrustedCertificatesUseCase usecase;

    this(ManageTrustedCertificatesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/custom-domain/trusted-certificates", &handleList);
        router.get("/api/v1/custom-domain/trusted-certificates/*", &handleGet);
        router.post("/api/v1/custom-domain/trusted-certificates", &handleCreate);
        router.delete_("/api/v1/custom-domain/trusted-certificates/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateTrustedCertificateRequest r;
        r.tenantId = tenantId;
        r.trustedCertificateId = TrustedCertificateId(precheck.id);
        r.customDomainId = CustomDomainId(data.getString("customDomainId"));
        r.certificatePem = data.getString("certificatePem");
        r.authMode = data.getString("authMode");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createCertificate(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Trusted certificate created successfully", "Created", 201, responseData);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto certs = usecase.listCertificates(tenantId);
        auto list = Json.emptyArray;
        foreach (c; certs) {
            list ~= Json.emptyObject
                .set("id", c.id)
                .set("customDomainId", c.customDomainId)
                .set("subjectDn", c.subjectDn)
                .set("issuerDn", c.issuerDn)
                .set("status", c.status.to!string)
                .set("authMode", c.authMode.to!string)
                .set("validFrom", c.validFrom)
                .set("validTo", c.validTo)
                .set("createdBy", c.createdBy)
                .set("createdAt", c.createdAt);
        }

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Trusted certificates retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TrustedCertificateId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid trusted certificate ID", 400);

        auto c = usecase.getCertificate(tenantId, id);
        if (c.isNull)
            return errorResponse("Trusted certificate not found", 404);

        auto responseData = Json.emptyObject
            .set("id", c.id)
            .set("customDomainId", c.customDomainId)
            .set("subjectDn", c.subjectDn)
            .set("issuerDn", c.issuerDn)
            .set("serialNumber", c.serialNumber)
            .set("fingerprint", c.fingerprint)
            .set("status", c.status.to!string)
            .set("authMode", c.authMode.to!string)
            .set("validFrom", c.validFrom)
            .set("validTo", c.validTo)
            .set("createdBy", c.createdBy)
            .set("createdAt", c.createdAt);

        return successResponse("Trusted certificate retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TrustedCertificateId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid trusted certificate ID", 400);

        auto result = usecase.deleteCertificate(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Trusted certificate deleted successfully", "Deleted", 200, responseData);
    }
}
