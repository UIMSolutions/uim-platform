/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.certificate;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class CertificateController : PlatformController {
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

    protected void handleGetCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreateCertificateRequest r;
            r.tenantId = tenantId;
            r.id = j.getString("id");
            r.keyId = j.getString("keyId");
            r.certificateType = j.getString("certificateType");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = certificates.createCertificate(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Certificate created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
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

            auto resp = Json.emptyObject
                .set("count", Json(certs.length))
                .set("resources", jarr)
                .set("message", "Certificates retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto path = req.requestURI.to!string;
            if (path.length > 13 && path[$ - 13 .. $] == "/upload-chain")
                return;
            if (path.length > 9 && path[$ - 9 .. $] == "/activate")
                return;
            if (path.length > 11 && path[$ - 11 .. $] == "/deactivate")
                return;

            auto id = extractIdFromPath(path);
            auto c = certificates.getCertificate(tenantId, id);
            if (c.isNull) {
                writeError(res, 404, "Certificate not found");
                return;
            }
            auto domainsArr = c.activatedDomains.map!(d => Json(d)).array.toJson;
            auto sansArr = c.subjectAlternativeNames.map!(s => Json(s)).array.toJson;

            auto resp = Json.emptyObject
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
                .set("subjectAlternativeNames", sansArr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetUploadChain(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 13]; // remove "/upload-chain"
            auto id = extractIdFromPath(stripped);

            auto j = req.json;
            UploadCertificateChainRequest r;
            r.tenantId = tenantId;
            r.id = id;
            r.certificatePem = j.getString("certificatePem");

            auto result = certificates.uploadCertificateChain(r);
            if (result.success) {
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Certificate chain uploaded");

                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 9]; // remove "/activate"
            auto id = extractIdFromPath(stripped);

            auto j = req.json;
            ActivateCertificateRequest r;
            r.tenantId = tenantId;
            r.id = id;
            r.domains = getStrings(j, "domains");

            auto result = certificates.activate(r);
            if (result.success) {
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Certificate activated");
                    
                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 11]; // remove "/deactivate"
            auto id = extractIdFromPath(stripped);

            auto result = certificates.deactivateCertificate(tenantId, id);
            if (result.success) {
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Certificate deactivated");

                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = certificates.deleteCertificate(tenantId, id);
            if (result.success) {
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Certificate deleted");

                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
