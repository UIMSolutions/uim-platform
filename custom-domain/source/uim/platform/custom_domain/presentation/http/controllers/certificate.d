/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.certificate;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class CertificateController : ManageController {
    private ManageCertificatesUseCase certificates;

    this(ManageCertificatesUseCase certificates) {
        this.certificates = certificates;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/custom-domain/certificates", &handleList);
        router.get("/api/v1/custom-domain/certificates/*", &handleGet);
        router.post("/api/v1/custom-domain/certificates", &handleCreate);
        router.post("/api/v1/custom-domain/certificates/*/upload-chain", &handleUploadChain);
        router.post("/api/v1/custom-domain/certificates/*/activate", &handleActivate);
        router.post("/api/v1/custom-domain/certificates/*/deactivate", &handleDeactivate);
        router.delete_("/api/v1/custom-domain/certificates/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto certs = certificates.listCertificates(tenantId);

        auto jarr = Json.emptyArray;
        foreach (c; certs) {
            jarr ~= Json.emptyObject
                .set("id", c.id)
                .set("keyId", c.keyId)
                .set("type", c.type.to!string)
                .set("status", c.status.to!string)
                .set("subjectDn", c.subjectDn)
                .set("issuerDn", c.issuerDn)
                .set("validFrom", c.validFrom)
                .set("validTo", c.validTo)
                .set("createdBy", c.createdBy)
                .set("createdAt", c.createdAt);
        }

        return successResponse("Certificates retrieved successfully", 200,
            Json.emptyObject.set("count", certs.length).set("resources", jarr));
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data; // Consistent with other createHandler implementations
        auto id = CertificateId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Certificate ID", 400);

        CreateCertificateRequest r;
        r.tenantId = tenantId;
        r.certificateId = id;
        r.keyId = data.getString("keyId");
        r.certificateType = data.getString("certificateType");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = certificates.createCertificate(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Certificate created", 201,
            Json.emptyObject.set("id", result.id));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto path = req.requestURI.to!string;
        enum UPLOAD_CHAIN_SUFFIX = "/upload-chain";
        enum ACTIVATE_SUFFIX = "/activate";
        enum DEACTIVATE_SUFFIX = "/deactivate";

        if (path.endsWith(UPLOAD_CHAIN_SUFFIX)) return errorResponse("Use the /upload-chain endpoint to upload certificate chains", 400);
        if (path.endsWith(ACTIVATE_SUFFIX)) return errorResponse("Use the /activate endpoint to activate certificates", 400);
        if (path.endsWith(DEACTIVATE_SUFFIX)) return errorResponse("Use the /deactivate endpoint to deactivate certificates", 400);

        // Extract ID from path, ensuring no suffix is present
        const idStr = extractIdFromPath(path);
        auto id = CertificateId(idStr);
        if (id.isNull)
            return errorResponse("Invalid Certificate ID", 400);

        auto c = certificates.getCertificate(tenantId, id);
        if (c.isNull) {
            return errorResponse("Certificate not found", 404);
        }
        auto domainsArr = c.activatedDomains.map!(d => d).array.toJson; // No need for Json(d) if d is string
        auto sansArr = c.subjectAlternativeNames.map!(s => s).array.toJson; // No need for Json(s) if s is string

        return successResponse("Certificate retrieved successfully", 200,
            Json.emptyObject
                    .set("id", c.id)
                    .set("keyId", c.keyId)
                    .set("type", c.type.to!string)
                    .set("status", c.status.to!string)
                    .set("subjectDn", c.subjectDn)
                    .set("issuerDn", c.issuerDn)
                    .set("serialNumber", c.serialNumber)
                    .set("fingerprint", c.fingerprint)
                    .set("validFrom", c.validFrom)
                    .set("validTo", c.validTo)
                    .set("createdBy", c.createdBy)
                    .set("createdAt", c.createdAt)
                    .set("activatedAt", c.activatedAt)
                    .set("activatedDomains", domainsArr)
                    .set("subjectAlternativeNames", sansArr) // Assuming sansArr is an array of strings
            );
    }

    protected Json uploadChainHandler(HTTPServerRequest req) {
        auto tenantId = req.getTenantId;
        if (tenantId.isNull)
            return errorResponse("Tenant ID is required", 400);

        const path = req.requestURI.to!string;
        enum UPLOAD_CHAIN_SUFFIX_LEN = "/upload-chain".length;
        auto stripped = path[0 .. $ - 13]; // remove "/upload-chain"
        auto id = CertificateId(extractIdFromPath(stripped));
        if (id.isNull) 
            return errorResponse("Invalid Certificate ID", 400);
        

        auto data = req.json;
        UploadCertificateChainRequest r;
        r.tenantId = tenantId;
        r.certificateId = id;
        r.certificatePem = data.getString("certificatePem");

        auto result = certificates.uploadCertificateChain(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Certificate chain uploaded", 200, Json.emptyObject.set("id", result
                .id));
    }

    protected void handleUploadChain(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto resp = uploadChainHandler(req);
            res.writeJsonBody(resp, resp.statusCode);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected Json activateHandler(HTTPServerRequest req) {
        auto tenantId = req.getTenantId;
        if (tenantId.isNull)
            return errorResponse("Tenant ID is required", 400);

        const path = req.requestURI.to!string;
        enum ACTIVATE_SUFFIX_LEN = "/activate".length;
        auto stripped = path[0 .. $ - 9]; // remove "/activate"
        auto id = CertificateId(extractIdFromPath(stripped));
        if (id.isNull) {
            return errorResponse("Invalid Certificate ID", 400);
        }

        auto data = req.json;
        ActivateCertificateRequest r;
        r.tenantId = tenantId;
        r.certificateId = id;
        r.domains = getStrings(data, "domains");

        auto result = certificates.activateCertificate(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Certificate activated", 200, Json.emptyObject.set("id", result.id));
    }

    protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto resp = activateHandler(req);
            res.writeJsonBody(resp, resp.statusCode);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected Json deactivateHandler(HTTPServerRequest req) {
        auto tenantId = req.getTenantId;
        if (tenantId.isNull) return errorResponse("Tenant ID is required", 400);

        const path = req.requestURI.to!string;
        enum DEACTIVATE_SUFFIX_LEN = "/deactivate".length;
        auto stripped = path[0 .. $ - DEACTIVATE_SUFFIX_LEN]; // remove "/deactivate"
        auto id = CertificateId(extractIdFromPath(stripped));
        if (id.isNull) return errorResponse("Invalid Certificate ID", 400);

        auto result = certificates.deactivateCertificate(tenantId, id);
        if (result.hasError) return errorResponse(result.message, 404);
        return successResponse("Certificate deactivated", 200, Json.emptyObject.set("id", result.id));
    }

    protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto resp = deactivateHandler(req);
            res.writeJsonBody(resp, resp.statusCode);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = Certificateprecheck.id);
        if (id.isNull)
            return errorResponse("Invalid Certificate ID", 400);

        auto result = certificates.deleteCertificate(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("Certificate deleted", 200,
            Json.emptyObject.set("id", result.id));
    }
}
