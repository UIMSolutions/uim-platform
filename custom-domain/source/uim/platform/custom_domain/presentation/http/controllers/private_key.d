/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.private_key;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class PrivateKeyController : ManageController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
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

        return successResponse("Private keys retrieved successfully", 200,
            Json.emptyObject.set("count", keys.length).set("keys", jarr));
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = PrivateKeyId(data.getString("id"));
        if (id.isNull)
            return errorResponse("Private key ID is required", 400);

        CreatePrivateKeyRequest r;
        r.tenantId = tenantId;
        r.privateKeyId = id;
        r.subject = data.getString("subject");
        r.domains = getStrings(data, "domains");
        r.algorithm = data.getString("algorithm");
        r.keySize = data.getInteger("keySize");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createPrivateKey(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Private key created successfully", 201,
            Json.emptyObject.set("id", result.id));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = PrivateKeyprecheck.id);
        if (id.isNull)
            return errorResponse("Invalid Private Key ID", 400);

        auto privateKey = usecase.getPrivateKey(tenantId, id);
        if (privateKey.isNull)
            return errorResponse("Private key not found", 404);

        auto domainsArr = privateKey.domains.map!(d => Json(d)).array.toJson;

        auto result = Json.emptyObject
                .set("entity", "PrivateKey")
                .set("id", privateKey.id)
                .set("tenantId", privateKey.tenantId)
                .set("subject", privateKey.subject)
                .set("algorithm", privateKey.algorithm.to!string)
                .set("status", privateKey.status.to!string)
                .set("keySize", privateKey.keySize)
                .set("publicKeyFingerprint", privateKey.publicKeyFingerprint)
                .set("createdBy", privateKey.createdBy)
                .set("createdAt", privateKey.createdAt)
                .set("domains", domainsArr);
                
        return successResponse("Private key retrieved successfully", 200, result);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = PrivateKeyprecheck.id);
        if (id.isNull)
            return errorResponse("Invalid Private Key ID", 400);

        auto result = usecase.deletePrivateKey(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("Private key deleted successfully", 200,
            Json.emptyObject.set("id", result.id));
    }
}
