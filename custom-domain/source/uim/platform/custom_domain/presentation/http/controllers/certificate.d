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

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateCertificateRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.keyId = j.getString("keyId");
            r.certificateType = j.getString("certificateType");
            r.createdBy = j.getString("createdBy");

            auto result = certificates.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Certificate created");
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
            auto certs = certificates.list(tenantId);

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
                .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            if (path.length > 13 && path[$ - 13 .. $] == "/upload-chain")
                return;
            if (path.length > 9 && path[$ - 9 .. $] == "/activate")
                return;
            if (path.length > 11 && path[$ - 11 .. $] == "/deactivate")
                return;

            auto id = extractIdFromPath(path);
            auto c = certificates.getById(id);
            if (c.id.isEmpty) {
                writeError(res, 404, "Certificate not found");
                return;
            }

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
                .set("activatedAt", c.activatedAt);

            auto domainsArr = Json.emptyArray;
            foreach (d; c.activatedDomains)
                domainsArr ~= Json(d);
            resp["activatedDomains"] = domainsArr;

            auto sansArr = Json.emptyArray;
            foreach (s; c.subjectAlternativeNames)
                sansArr ~= Json(s);
            resp["subjectAlternativeNames"] = sansArr;

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUploadChain(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 13]; // remove "/upload-chain"
            auto id = extractIdFromPath(stripped);

            auto j = req.json;
            UploadCertificateChainRequest r;
            r.tenantId = req.getTenantId;
            r.id = id;
            r.certificatePem = j.getString("certificatePem");

            auto result = certificates.uploadChain(r);
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

    private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 9]; // remove "/activate"
            auto id = extractIdFromPath(stripped);

            auto j = req.json;
            ActivateCertificateRequest r;
            r.tenantId = req.getTenantId;
            r.id = id;
            r.domains = getStringArray(j, "domains");

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

    private void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 11]; // remove "/deactivate"
            auto id = extractIdFromPath(stripped);

            auto result = certificates.deactivate(id);
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

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = certificates.remove(id);
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
