/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.presentation.http.controllers.screen_set;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class ScreenSetController : PlatformController {
    private ManageScreenSetsUseCase screenSets;

    this(ManageScreenSetsUseCase screenSets) {
        this.screenSets = screenSets;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/customer-identity/screen-sets", &handleList);
        router.get("/api/v1/customer-identity/screen-sets/*", &handleGet);
        router.post("/api/v1/customer-identity/screen-sets", &handleCreate);
        router.put("/api/v1/customer-identity/screen-sets/*", &handleUpdate);
        router.delete_("/api/v1/customer-identity/screen-sets/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto items = screenSets.listScreenSets(tenantId);
        auto jarr = items.map!(e => e.toJson()).array.toJson;

        return Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr)
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto j = req.json;

        ScreenSetDTO dto;
        dto.tenantId = tenantId;
        dto.name = j.getString("name");
        dto.description = j.getString("description");
        dto.flowType = j.getString("flowType");
        dto.htmlContent = j.getString("htmlContent");
        dto.cssContent = j.getString("cssContent");
        dto.jsContent = j.getString("jsContent");
        dto.locale = j.getString("locale");
        dto.version_ = j.getString("version");
        dto.createdBy = UserId(j.getString("createdBy"));

        auto result = screenSets.createScreenSet(dto);
        if (result.success)
            return Json.emptyObject.set("id", result.id).set("message", "Screen set created").set("status", "success").set("statusCode", 201);
        return Json.emptyObject.set("error", result.error).set("status", "error").set("statusCode", 400);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto path = req.requestURI.to!string;
        auto id = ScreenSetId(extractIdFromPath(path));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Screen Set ID").set("status", "error").set("statusCode", 400);

        auto e = screenSets.getScreenSet(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Screen set not found").set("status", "error").set("statusCode", 404);

        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto path = req.requestURI.to!string;
        auto id = ScreenSetId(extractIdFromPath(path));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Screen Set ID").set("status", "error").set("statusCode", 400);

        auto j = req.json;
        ScreenSetDTO dto;
        dto.screenSetId = id;
        dto.tenantId = tenantId;
        dto.name = j.getString("name");
        dto.description = j.getString("description");
        dto.htmlContent = j.getString("htmlContent");
        dto.cssContent = j.getString("cssContent");
        dto.jsContent = j.getString("jsContent");
        dto.locale = j.getString("locale");
        dto.version_ = j.getString("version");
        dto.updatedBy = UserId(j.getString("updatedBy"));

        auto result = screenSets.updateScreenSet(dto);
        if (result.success)
            return Json.emptyObject.set("id", result.id).set("message", "Screen set updated").set("status", "success").set("statusCode", 200);
        return Json.emptyObject.set("error", result.error).set("status", "error").set("statusCode", 400);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto path = req.requestURI.to!string;
        auto id = ScreenSetId(extractIdFromPath(path));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Screen Set ID").set("status", "error").set("statusCode", 400);

        auto result = screenSets.deleteScreenSet(tenantId, id);
        if (result.success)
            return Json.emptyObject.set("message", "Screen set deleted").set("status", "success").set("statusCode", 200);
        return Json.emptyObject.set("error", result.error).set("status", "error").set("statusCode", 404);
    }
}
