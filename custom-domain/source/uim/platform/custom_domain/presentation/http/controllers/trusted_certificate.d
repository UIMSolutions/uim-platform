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
    private ManageTrustedCertificatesUseCase uc;

    this(ManageTrustedCertificatesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/custom-domain/trusted-certificates", &handleList);
        router.get("/api/v1/custom-domain/trusted-certificates/*", &handleGet);
        router.post("/api/v1/custom-domain/trusted-certificates", &handleCreate);
        router.delete_("/api/v1/custom-domain/trusted-certificates/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateTrustedCertificateRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.customDomainId = j.getString("customDomainId");
            r.certificatePem = j.getString("certificatePem");
            r.authMode = j.getString("authMode");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Trusted certificate created");
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
            auto certs = uc.list(tenantId);

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
                .set("resources", jarr);
            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto c = uc.get_(id);
            if (c.id.isEmpty) {
                writeError(res, 404, "Trusted certificate not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(c.id);
            resp["customDomainId"] = Json(c.customDomainId);
            resp["subjectDn"] = Json(c.subjectDn);
            resp["issuerDn"] = Json(c.issuerDn);
            resp["serialNumber"] = Json(c.serialNumber);
            resp["fingerprint"] = Json(c.fingerprint);
            resp["status"] = Json(c.status.to!string);
            resp["authMode"] = Json(c.authMode.to!string);
            resp["validFrom"] = Json(c.validFrom);
            resp["validTo"] = Json(c.validTo);
            resp["createdBy"] = Json(c.createdBy);
            resp["createdAt"] = Json(c.createdAt);
            res.writeJsonBody(resp, 200);
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
                resp["message"] = Json("Trusted certificate deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
