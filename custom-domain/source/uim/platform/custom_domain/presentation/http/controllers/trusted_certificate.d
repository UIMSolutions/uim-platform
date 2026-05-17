/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.trusted_certificate;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class TrustedCertificateController : PlatformController {
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

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreateTrustedCertificateRequest r;
            r.tenantId = tenantId;
            r.trustedCertificateId = TrustedCertificateId(j.getString("id"));
            r.customDomainId = CustomDomainId(j.getString("customDomainId"));
            r.certificatePem = j.getString("certificatePem");
            r.authMode = j.getString("authMode");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createCertificate(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Trusted certificate created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto certs = usecase.listCertificates(tenantId);

            auto jarr = Json.emptyArray;
            foreach (c; certs) {
                jarr ~= Json.emptyObject
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

            auto response = Json.emptyObject
                .set("count", certs.length)
                .set("resources", jarr)
                .set("message", "Trusted certificates retrieved successfully");

            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TrustedCertificateId(extractIdFromPath(req.requestURI.to!string));

            auto c = usecase.getCertificate(tenantId, id);
            if (c.isNull) {
                writeError(res, 404, "Trusted certificate not found");
                return;
            }

            auto resp = Json.emptyObject
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
                
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TrustedCertificateId(extractIdFromPath(req.requestURI.to!string));

            auto result = usecase.deleteCertificate(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Trusted certificate deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
