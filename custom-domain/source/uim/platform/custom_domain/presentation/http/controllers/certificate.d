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
            return errorResponse(precheck.error, 400);

        auto tenantId = getTenantId(precheck);
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

        return Json.emptyObject
            .set("count", Json(certs.length))
            .set("resources", jarr)
            .set("message", "Certificates retrieved successfully");
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return errorResponse(precheck.error, 400);

        auto tenantId = getTenantId(precheck);
        auto data = req.json;

        CreateCertificateRequest r;
        r.tenantId = tenantId;
        r.certificateId = CertificateId(data.getString("id"));
        r.keyId = data.getString("keyId");
        r.certificateType = data.getString("certificateType");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = certificates.createCertificate(r);
        if (result.hasError) {
            return Json.emptyObject
                .set("error", result.errorMessage)
                .set("status", "error")
                .set("statusCode", 404);
        }

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Certificate created")
            .set("status", "success")
            .set("statusCode", 201);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return errorResponse(precheck.error, 400);

        auto tenantId = getTenantId(precheck);

        auto path = req.requestURI.to!string;
        if (path.length > 13 && path[$ - 13 .. $] == "/upload-chain")
            return;
        if (path.length > 9 && path[$ - 9 .. $] == "/activate")
            return;
        if (path.length > 11 && path[$ - 11 .. $] == "/deactivate")
            return;

        auto id = CertificateId(extractIdFromPath(path));
        if (id.isNull)
            return errorResponse("Invalid Certificate ID", 400);

        auto c = certificates.getCertificate(tenantId, id);
        if (c.isNull) {
            return errorResponse("Certificate not found", 404);
        }
        auto domainsArr = c.activatedDomains.map!(d => Json(d)).array.toJson;
        auto sansArr = c.subjectAlternativeNames.map!(s => Json(s)).array.toJson;

        return Json.emptyObject
            .set("message", "Certificate retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200)
            .set("item", Json.emptyObject
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
                    .set("subjectAlternativeNames", sansArr)
            );
    }

    protected void handleUploadChain(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            if (tenantId.isNull) {
                writeError(res, 400, "Missing tenant ID");
                return;
            }

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 13]; // remove "/upload-chain"
            auto id = CertificateId(extractIdFromPath(stripped));

            auto j = req.json;
            UploadCertificateChainRequest r;
            r.tenantId = tenantId;
            r.certificateId = id;
            r.certificatePem = j.getString("certificatePem");

            auto result = certificates.uploadCertificateChain(r);
            if (result.success) {
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Certificate chain uploaded");

                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 400, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            if (tenantId.isNull) {
                writeError(res, 400, "Missing tenant ID");
                return;
            }

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 9]; // remove "/activate"
            auto id = CertificateId(extractIdFromPath(stripped));
            if (id.isNull) {
                writeError(res, 400, "Invalid Certificate ID");
                return;
            }

            auto j = req.json;
            ActivateCertificateRequest r;
            r.tenantId = tenantId;
            r.certificateId = id;
            r.domains = getStrings(j, "domains");

            auto result = certificates.activateCertificate(r);
            if (result.success) {
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Certificate activated");

                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 400, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            if (tenantId.isNull) {
                writeError(res, 400, "Missing tenant ID");
                return;
            }

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 11]; // remove "/deactivate"
            auto id = CertificateId(extractIdFromPath(stripped));
            if (id.isNull) {
                writeError(res, 400, "Invalid Certificate ID");
                return;
            }

            auto result = certificates.deactivateCertificate(tenantId, id);
            if (result.success) {
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Certificate deactivated");

                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 404, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return errorResponse(precheck.error, 400);

        auto tenantId = getTenantId(precheck);
        auto id = CertificateId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull) {
            writeError(res, 400, "Invalid Certificate ID");
            return;
        }

        auto result = certificates.deleteCertificate(tenantId, id);
        if (result.hasError) {
            return Json.emptyObject
                .set("error", result.errorMessage)
                .set("status", "error")
                .set("statusCode", 404);
        }

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Certificate deleted");

    }
}
