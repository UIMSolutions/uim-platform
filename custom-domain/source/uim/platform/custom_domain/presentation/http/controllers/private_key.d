/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.private_key;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class PrivateKeyController : PlatformController {
    private ManagePrivateKeysUseCase uc;

    this(ManagePrivateKeysUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/custom-domain/keys", &handleList);
        router.get("/api/v1/custom-domain/keys/*", &handleGet);
        router.post("/api/v1/custom-domain/keys", &handleCreate);
        router.delete_("/api/v1/custom-domain/keys/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreatePrivateKeyRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.subject = j.getString("subject");
            r.domains = getStringArray(j, "domains");
            r.algorithm = j.getString("algorithm");
            r.keySize = j.getInteger("keySize");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Private key created");

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
            auto keys = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (k; keys) {
                jarr ~= Json.emptyObject
                    .set("id", k.id)
                    .set("subject", k.subject)
                    .set("algorithm", k.algorithm.to!string)
                    .set("status", k.status.to!string)
                    .set("keySize", k.keySize)
                    .set("createdBy", k.createdBy)
                    .set("createdAt", k.createdAt);
            }

            auto resp = Json.emptyObject
                .set("count", Json(keys.length))
                .set("resources", jarr);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto k = uc.getById(id);
            if (k.isNull) {
                writeError(res, 404, "Private key not found");
                return;
            }

            auto domainsArr = Json.emptyArray;
            foreach (d; k.domains) {
                domainsArr ~= Json(d);
            }

            auto resp = Json.emptyObject
                .set("id", Json(k.id))
                .set("subject", Json(k.subject))
                .set("algorithm", Json(k.algorithm.to!string))
                .set("status", Json(k.status.to!string))
                .set("keySize", Json(k.keySize))
                .set("publicKeyFingerprint", Json(k.publicKeyFingerprint))
                .set("createdBy", Json(k.createdBy))
                .set("createdAt", Json(k.createdAt))
                .set("domains", domainsArr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.removeById(id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Private key deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
