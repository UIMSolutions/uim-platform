module uim.platform.management.presentation.http.controllers.entitlement;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;

import uim.platform.connectivity.application.usecases.manage_entitlements;
import uim.platform.connectivity.application.dto;
import uim.platform.management.domain.entities.entitlement;
import uim.platform.management.domain.types;
import presentation.http.json_utils;

class EntitlementController {
    private ManageEntitlementsUseCase uc;

    this(ManageEntitlementsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        router.post("/api/v1/entitlements", &handleAssign);
        router.get("/api/v1/entitlements", &handleList);
        router.get("/api/v1/entitlements/*", &handleGet);
        router.put("/api/v1/entitlements/*", &handleUpdateQuota);
        router.post("/api/v1/entitlements/revoke/*", &handleRevoke);
        router.delete_("/api/v1/entitlements/*", &handleDelete);
    }

    private void handleAssign(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            AssignEntitlementRequest r;
            r.globalAccountId = j.getString("globalAccountId");
            r.directoryId = j.getString("directoryId");
            r.subaccountId = j.getString("subaccountId");
            r.servicePlanId = j.getString("servicePlanId");
            r.serviceName = j.getString("serviceName");
            r.planName = j.getString("planName");
            r.quotaAssigned = j.getInteger("quotaAssigned");
            r.unlimited = j.getBoolean("unlimited");
            r.autoAssign = j.getBoolean("autoAssign");
            r.assignedBy = req.headers.get("X-User-Id", "");

            auto result = uc.assign(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            } else
                writeError(res, 400, result.error);
        } catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto gaId = req.params.get("globalAccountId");
            auto subId = req.params.get("subaccountId");
            auto dirId = req.params.get("directoryId");

            Entitlement[] items;
            if (subId.length > 0)
                items = uc.listBySubaccount(subId);
            else if (dirId.length > 0)
                items = uc.listByDirectory(dirId);
            else if (gaId.length > 0)
                items = uc.listByGlobalAccount(gaId);

            auto arr = Json.emptyArray;
            foreach (ref e; items)
                arr ~= serializeEntitlement(e);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)items.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractId(req.requestURI);
            auto ent = uc.getById(id);
            if (ent.id.length == 0) {
                writeError(res, 404, "Entitlement not found");
                return;
            }
            res.writeJsonBody(serializeEntitlement(ent), 200);
        } catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleUpdateQuota(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractId(req.requestURI);
            auto j = req.json;
            UpdateEntitlementQuotaRequest r;
            r.quotaAssigned = j.getInteger("quotaAssigned");
            r.unlimited = j.getBoolean("unlimited");

            auto result = uc.updateQuota(id, r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 200);
            else
                writeError(res, 404, result.error);
        } catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractId(req.requestURI);
            auto result = uc.revoke(id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 200);
            else
                writeError(res, 400, result.error);
        } catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractId(req.requestURI);
            auto result = uc.remove(id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject, 204);
            else
                writeError(res, 404, result.error);
        } catch (Exception e)
            writeError(res, 500, "Internal server error");
    }
}

private Json serializeEntitlement(ref Entitlement e) {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["globalAccountId"] = Json(e.globalAccountId);
    j["directoryId"] = Json(e.directoryId);
    j["subaccountId"] = Json(e.subaccountId);
    j["servicePlanId"] = Json(e.servicePlanId);
    j["serviceName"] = Json(e.serviceName);
    j["planName"] = Json(e.planName);
    j["planDisplayName"] = Json(e.planDisplayName);
    j["category"] = Json(enumStr(e.category));
    j["status"] = Json(enumStr(e.status));
    j["quotaAssigned"] = Json(cast(long)e.quotaAssigned);
    j["quotaUsed"] = Json(cast(long)e.quotaUsed);
    j["quotaRemaining"] = Json(cast(long)e.quotaRemaining);
    j["unlimited"] = Json(e.unlimited);
    j["autoAssign"] = Json(e.autoAssign);
    j["assignedAt"] = Json(e.assignedAt);
    j["modifiedAt"] = Json(e.modifiedAt);
    j["assignedBy"] = Json(e.assignedBy);
    return j;
}

private string enumStr(E)(E val) {
    import std.conv : to;

    return val.to!string;
}
