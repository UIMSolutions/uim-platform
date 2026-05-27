/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.presentation.http.controllers.customer_session;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class CustomerSessionController : ManageController {
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

        auto tenantId = precheck.tenantId;
        auto items = sessions.listSessions(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

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

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        CustomerSessionDTO dto;
        dto.tenantId = tenantId;
        dto.customerId = CustomerId(data.getString("customerId"));
        dto.token = data.getString("token");
        dto.deviceInfo = data.getString("deviceInfo");
        dto.ipAddress = data.getString("ipAddress");
        dto.userAgent = data.getString("userAgent");
        dto.expiresAt = data.getInteger("expiresAt");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = sessions.createSession(dto);
        if (result.success)
            return Json.emptyObject.set("id", result.id).set("message", "Session created").set("status", "success").set("statusCode", 201);
        return Json.emptyObject.set("error", result.message).set("status", "error").set("statusCode", 400);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = CustomerSessionId(precheck.id);
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

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = CustomerSessionId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Session ID").set("status", "error").set("statusCode", 400);

        auto result = sessions.revokeSession(tenantId, id);
        if (result.success)
            return Json.emptyObject.set("message", "Session revoked").set("status", "success").set("statusCode", 200);
        return Json.emptyObject.set("error", result.message).set("status", "error").set("statusCode", 404);
    }
}
