/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.presentation.http.controllers.credential;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

class CredentialController : ManageHttpController {
    private ManageCredentialsUseCase creds;

    this(ManageCredentialsUseCase creds) {
        this.creds = creds;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/integration-delivery/credentials", &handleList);
        router.get("/api/v1/integration-delivery/credentials/*", &handleGet);
        router.post("/api/v1/integration-delivery/credentials", &handleCreate);
        router.put("/api/v1/integration-delivery/credentials/*", &handleUpdate);
        router.delete_("/api/v1/integration-delivery/credentials/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = creds.listCredentials(tenantId);
        auto responseData = Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson);

        return successResponse("Credentials retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = CredentialId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid credential ID").set("statusCode", 400);

        auto e = creds.getCredential(tenantId, id);
        if (e.isNull)
            return errorResponse("Credential not found", 404);

        return successResponse("Credential retrieved successfully", "Retrieved", 200, e.toJson);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        CredentialDTO dto;
        dto.credentialId = CredentialId(data.getString("credentialId", ""));
        dto.tenantId = tenantId;
        dto.name = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.username = data.getString("username", "");
        dto.secretRef = data.getString("secretRef", "");
        dto.target = data.getString("target", "");
        dto.createdBy = UserId(data.getString("createdBy", ""));

        auto result = creds.createCredential(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject.set("id", result.id).set("message", "Credential created").set("status", "created").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = CredentialId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid credential ID").set("statusCode", 400);

        CredentialDTO dto;
        dto.tenantId = tenantId;
        dto.credentialId = id;
        dto.name = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.target = data.getString("target", "");
        dto.updatedBy = UserId(data.getString("updatedBy", ""));

        auto result = creds.updateCredential(dto);
        if (result.hasError)
        return errorResponse(result.message, 400);

        return successResponse("Credential updated successfully", "Updated", 200, Json.emptyObject.set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = CredentialId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid credential ID").set("statusCode", 400);

        auto result = creds.deleteCredential(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Credential deleted successfully", "Deleted", 200, Json.emptyObject.set("id", result.id)); e", 200);
    }
}
