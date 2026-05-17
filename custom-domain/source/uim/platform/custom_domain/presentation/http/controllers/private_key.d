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
    private ManagePrivateKeysUseCase usecase;

    this(ManagePrivateKeysUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/custom-domain/keys", &handleList);
        router.get("/api/v1/custom-domain/keys/*", &handleGet);
        router.post("/api/v1/custom-domain/keys", &handleCreate);
        router.delete_("/api/v1/custom-domain/keys/*", &handleDelete);
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreatePrivateKeyRequest r;
            r.tenantId = tenantId;
            r.privateKeyId = PrivateKeyId(j.getString("id"));
            r.subject = j.getString("subject");
            r.domains = getStrings(j, "domains");
            r.algorithm = j.getString("algorithm");
            r.keySize = j.getInteger("keySize");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createPrivateKey(r);
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

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto keys = usecase.listPrivateKeys(tenantId);

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

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = PrivateKeyId(extractIdFromPath(req.requestURI.to!string));
            
            auto k = usecase.getPrivateKey(tenantId, id);
            if (k.isNull) {
                writeError(res, 404, "Private key not found");
                return;
            }

            auto domainsArr = k.domains.map!(d => Json(d)).array.toJson;
            
            auto resp = Json.emptyObject
                .set("id", k.id)
                .set("tenantId", k.tenantId)
                .set("subject", k.subject)
                .set("algorithm", k.algorithm.to!string)
                .set("status", k.status.to!string)
                .set("keySize", k.keySize)
                .set("publicKeyFingerprint", k.publicKeyFingerprint)
                .set("createdBy", k.createdBy)
                .set("createdAt", k.createdAt)
                .set("domains", domainsArr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = PrivateKeyId(extractIdFromPath(req.requestURI.to!string));

            auto result = usecase.deletePrivateKey(tenantId, id);
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
