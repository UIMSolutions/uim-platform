/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.presentation.http.controllers.customer_session;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class CustomerSessionController : PlatformController {
    private ManageCustomerSessionsUseCase sessions;

    this(ManageCustomerSessionsUseCase sessions) {
        this.sessions = sessions;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/customer-identity/sessions", &handleList);
        router.get("/api/v1/customer-identity/sessions/*", &handleGet);
        router.post("/api/v1/customer-identity/sessions", &handleCreate);
        router.delete_("/api/v1/customer-identity/sessions/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = getTenantId(precheck);
        auto items = sessions.listSessions(tenantId);
        auto jarr = items.map!(e => e.toJson()).array.toJson;

        return Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr)
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = getTenantId(precheck);
        auto j = req.json;

        CustomerSessionDTO dto;
        dto.tenantId = tenantId;
        dto.customerId = CustomerId(j.getString("customerId"));
        dto.token = j.getString("token");
        dto.deviceInfo = j.getString("deviceInfo");
        dto.ipAddress = j.getString("ipAddress");
        dto.userAgent = j.getString("userAgent");
        dto.expiresAt = j.getInt("expiresAt");
        dto.createdBy = UserId(j.getString("createdBy"));

        auto result = sessions.createSession(dto);
        if (result.success)
            return Json.emptyObject.set("id", result.id).set("message", "Session created").set("status", "success").set("statusCode", 201);
        return Json.emptyObject.set("error", result.errorMessage).set("status", "error").set("statusCode", 400);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = getTenantId(precheck);
        auto path = req.requestURI.to!string;
        auto id = CustomerSessionId(extractIdFromPath(path));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Session ID").set("status", "error").set("statusCode", 400);

        auto e = sessions.getSession(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Session not found").set("status", "error").set("statusCode", 404);

        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = getTenantId(precheck);
        auto path = req.requestURI.to!string;
        auto id = CustomerSessionId(extractIdFromPath(path));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Session ID").set("status", "error").set("statusCode", 400);

        auto result = sessions.revokeSession(tenantId, id);
        if (result.success)
            return Json.emptyObject.set("message", "Session revoked").set("status", "success").set("statusCode", 200);
        return Json.emptyObject.set("error", result.errorMessage).set("status", "error").set("statusCode", 404);
    }
}
