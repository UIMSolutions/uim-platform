/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.certificate;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class CertificateController : SAPController {
    private ManageCertificatesUseCase uc;

    this(ManageCertificatesUseCase uc) {
        this.uc = uc;
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
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = j.getString("id");
            r.keyId = j.getString("keyId");
            r.certificateType = j.getString("certificateType");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Certificate created");
                res.writeJsonBody(resp, 201);
            } ) {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto certs = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref c; certs) {
                auto cj = Json.emptyObject;
                cj["id"] = Json(c.id);
                cj["keyId"] = Json(c.keyId);
                cj["type"] = Json(c.type.to!string);
                cj["status"] = Json(c.status.to!string);
                cj["subjectDn"] = Json(c.subjectDn);
                cj["issuerDn"] = Json(c.issuerDn);
                cj["validFrom"] = Json(c.validFrom);
                cj["validTo"] = Json(c.validTo);
                cj["createdBy"] = Json(c.createdBy);
                cj["createdAt"] = Json(c.createdAt);
                jarr ~= cj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) certs.length);
            resp["resources"] = jarr;
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
            auto c = uc.get_(id);
            if (c.id.length == 0) {
                writeError(res, 404, "Certificate not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(c.id);
            resp["keyId"] = Json(c.keyId);
            resp["type"] = Json(c.type.to!string);
            resp["status"] = Json(c.status.to!string);
            resp["subjectDn"] = Json(c.subjectDn);
            resp["issuerDn"] = Json(c.issuerDn);
            resp["serialNumber"] = Json(c.serialNumber);
            resp["fingerprint"] = Json(c.fingerprint);
            resp["validFrom"] = Json(c.validFrom);
            resp["validTo"] = Json(c.validTo);
            resp["createdBy"] = Json(c.createdBy);
            resp["createdAt"] = Json(c.createdAt);
            resp["activatedAt"] = Json(c.activatedAt);

            auto domainsArr = Json.emptyArray;
            foreach (ref d; c.activatedDomains)
                domainsArr ~= Json(d);
            resp["activatedDomains"] = domainsArr;

            auto sansArr = Json.emptyArray;
            foreach (ref s; c.subjectAlternativeNames)
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
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = id;
            r.certificatePem = j.getString("certificatePem");

            auto result = uc.uploadChain(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Certificate chain uploaded");
                res.writeJsonBody(resp, 200);
            } ) {
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
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = id;
            r.domains = jsonStrArray(j, "domains");

            auto result = uc.activate(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Certificate activated");
                res.writeJsonBody(resp, 200);
            } ) {
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

            auto result = uc.deactivate(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Certificate deactivated");
                res.writeJsonBody(resp, 200);
            } ) {
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
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Certificate deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
