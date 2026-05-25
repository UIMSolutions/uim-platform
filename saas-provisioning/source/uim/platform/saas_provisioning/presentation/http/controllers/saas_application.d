/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.presentation.http.controllers.saas_application;

import uim.platform.saas_provisioning;
import std.conv : to;

mixin(ShowModule!());

@safe:

/// REST controller — Provider: register / list / get / update / deregister SaaS applications.
///
///   GET    /api/v1/saas-provisioning/applications
///   POST   /api/v1/saas-provisioning/applications
///   GET    /api/v1/saas-provisioning/applications/*
///   PUT    /api/v1/saas-provisioning/applications/*
///   DELETE /api/v1/saas-provisioning/applications/*
class SaasApplicationController : PlatformController {
    private ManageSaasApplicationsUseCase usecase;

    this(ManageSaasApplicationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get(    "/api/v1/saas-provisioning/applications",   &handleList);
        router.post(   "/api/v1/saas-provisioning/applications",   &handleCreate);
        router.get(    "/api/v1/saas-provisioning/applications/*", &handleGet);
        router.put(    "/api/v1/saas-provisioning/applications/*", &handleUpdate);
        router.delete_("/api/v1/saas-provisioning/applications/*", &handleDelete);
    }

    // -----------------------------------------------------------------------

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto apps = usecase.listApplications(tenantId);
            auto arr = Json.emptyArray;
            foreach (a; apps) arr ~= a.toJson();
            res.writeJsonBody(
                Json.emptyObject.set("count", apps.length).set("applications", arr), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto body_    = req.json;

            RegisterAppRequest dto;
            dto.appName               = body_["appName"].get!string;
            dto.displayName           = body_["displayName"].get!string;
            dto.description           = safeStr(body_, "description");
            dto.category              = safeStr(body_, "category");
            dto.plan                  = safeEnum!AppPlan(body_, "plan", AppPlan.application);
            dto.providerSubaccountId  = safeStr(body_, "providerSubaccountId");
            dto.globalAccountId       = safeStr(body_, "globalAccountId");
            dto.xsuaaServiceInstanceId = safeStr(body_, "xsuaaServiceInstanceId");
            dto.autoSubscribeGlobalAccounts = safeBool(body_, "autoSubscribeGlobalAccounts");
            if ("appUrls" in body_) {
                auto u = body_["appUrls"];
                dto.appUrls.onSubscriptionUrl   = safeStr(u, "onSubscriptionUrl");
                dto.appUrls.onUnsubscriptionUrl = safeStr(u, "onUnsubscriptionUrl");
                dto.appUrls.onUpdateUrl         = safeStr(u, "onUpdateUrl");
                dto.appUrls.getDependenciesUrl  = safeStr(u, "getDependenciesUrl");
                dto.appUrls.appBaseUrl          = safeStr(u, "appBaseUrl");
            }

            auto result = usecase.registerApplication(tenantId, dto);
            if (!result.success) { writeError(res, 400, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
        } catch (Exception e) {
            writeError(res, 400, "Invalid request: " ~ e.msg);
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = SaasApplicationId(extractIdFromPath(req.requestURI.to!string));
            auto app = usecase.getApplication(tenantId, id);
            if (app.isNull) { writeError(res, 404, "Application not found"); return; }
            res.writeJsonBody(app.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id       = SaasApplicationId(extractIdFromPath(req.requestURI.to!string));
            auto body_    = req.json;

            UpdateAppRequest dto;
            dto.displayName                 = safeStr(body_, "displayName");
            dto.description                 = safeStr(body_, "description");
            dto.category                    = safeStr(body_, "category");
            dto.plan                        = safeEnum!AppPlan(body_, "plan", AppPlan.application);
            dto.autoSubscribeGlobalAccounts = safeBool(body_, "autoSubscribeGlobalAccounts");
            if ("appUrls" in body_) {
                auto u = body_["appUrls"];
                dto.appUrls.onSubscriptionUrl   = safeStr(u, "onSubscriptionUrl");
                dto.appUrls.onUnsubscriptionUrl = safeStr(u, "onUnsubscriptionUrl");
                dto.appUrls.onUpdateUrl         = safeStr(u, "onUpdateUrl");
                dto.appUrls.getDependenciesUrl  = safeStr(u, "getDependenciesUrl");
                dto.appUrls.appBaseUrl          = safeStr(u, "appBaseUrl");
            }

            auto result = usecase.updateApplication(tenantId, id, dto);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
        } catch (Exception e) {
            writeError(res, 400, "Invalid request: " ~ e.msg);
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = SaasApplicationId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deregisterApplication(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    // -----------------------------------------------------------------------
    // JSON helpers
    // -----------------------------------------------------------------------

    private string safeStr(Json obj, string key) {
        if ((key in obj) !is null && obj[key].type == Json.Type.string) return obj[key].get!string;
        return "";
    }

    private bool safeBool(Json obj, string key) {
        if ((key in obj) !is null && obj[key].type == Json.Type.bool_) return obj[key].get!bool;
        return false;
    }

    private E safeEnum(E)(Json obj, string key, E default_) {
        if ((key in obj) !is null && obj[key].type == Json.Type.string) {
            try { return obj[key].get!string.to!E; } catch (Exception) {}
        }
        return default_;
    }
}
