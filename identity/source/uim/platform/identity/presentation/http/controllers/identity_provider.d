/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.presentation.http.controllers.identity_provider;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class IdentityProviderController : ManageController {
    private ManageIdentityProvidersUseCase usecase;

    this(ManageIdentityProvidersUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/ias/identity-providers", &handleList);
        router.get("/api/v1/ias/identity-providers/*", &handleGet);
        router.post("/api/v1/ias/identity-providers", &handleCreate);
        router.put("/api/v1/ias/identity-providers/*", &handleUpdate);
        router.delete_("/api/v1/ias/identity-providers/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listIdentityProviders(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Identity providers retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = IdentityProviderprecheck.id);
            auto e = usecase.getIdentityProvider(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Identity provider not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            IdentityProviderDTO dto;
            dto.idpId = IdentityProviderId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.type_ = j.getString("type");
            dto.entityId = j.getString("entityId");
            dto.ssoUrl = j.getString("ssoUrl");
            dto.sloUrl = j.getString("sloUrl");
            dto.metadataUrl = j.getString("metadataUrl");
            dto.clientId = j.getString("clientId");
            dto.isDefault = j.getBoolean("isDefault");

            auto result = usecase.createIdentityProvider(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Identity provider created successfully"), 201);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            IdentityProviderDTO dto;
            dto.idpId = IdentityProviderprecheck.id);
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.ssoUrl = j.getString("ssoUrl");
            dto.sloUrl = j.getString("sloUrl");
            dto.metadataUrl = j.getString("metadataUrl");
            dto.status = j.getString("status");
            dto.isDefault = j.getBoolean("isDefault");

            auto result = usecase.updateIdentityProvider(dto);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Identity provider updated successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = IdentityProviderprecheck.id);
            auto result = usecase.deleteIdentityProvider(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Identity provider deleted successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
