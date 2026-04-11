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
            r.domains = jsonStrArray(j, "domains");
            r.algorithm = j.getString("algorithm");
            r.keySize = jsonInt(j, "keySize");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Private key created");
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
                auto kj = Json.emptyObject;
                kj["id"] = Json(k.id);
                kj["subject"] = Json(k.subject);
                kj["algorithm"] = Json(k.algorithm.to!string);
                kj["status"] = Json(k.status.to!string);
                kj["keySize"] = Json(k.keySize);
                kj["createdBy"] = Json(k.createdBy);
                kj["createdAt"] = Json(k.createdAt);
                jarr ~= kj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(keys.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto k = uc.get_(id);
            if (k.id.isEmpty) {
                writeError(res, 404, "Private key not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(k.id);
            resp["subject"] = Json(k.subject);
            resp["algorithm"] = Json(k.algorithm.to!string);
            resp["status"] = Json(k.status.to!string);
            resp["keySize"] = Json(k.keySize);
            resp["publicKeyFingerprint"] = Json(k.publicKeyFingerprint);
            resp["createdBy"] = Json(k.createdBy);
            resp["createdAt"] = Json(k.createdAt);

            auto domainsArr = Json.emptyArray;
            foreach (d; k.domains)
                domainsArr ~= Json(d);
            resp["domains"] = domainsArr;

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
                resp["message"] = Json("Private key deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
