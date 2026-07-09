/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.presentation.http.controllers.saas_application;

import uim.platform.saas_provisioning;

mixin(ShowModule!());

@safe:

/// REST controller — Provider: register / list / get / update / deregister SaaS applications.
///
///   GET    /api/v1/saas-provisioning/applications
///   POST   /api/v1/saas-provisioning/applications
///   GET    /api/v1/saas-provisioning/applications/*
///   PUT    /api/v1/saas-provisioning/applications/*
///   DELETE /api/v1/saas-provisioning/applications/*
class SaasApplicationController : ManageHttpController {
    private ManageSaasApplicationsUseCase usecase;

    this(ManageSaasApplicationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/saas-provisioning/applications", &handleList);
        router.post("/api/v1/saas-provisioning/applications", &handleCreate);
        router.get("/api/v1/saas-provisioning/applications/*", &handleGet);
        router.put("/api/v1/saas-provisioning/applications/*", &handleUpdate);
        router.delete_("/api/v1/saas-provisioning/applications/*", &handleDelete);
    }

    // -----------------------------------------------------------------------

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto apps = usecase.listApplications(tenantId);
        auto arr = apps.map!(a => a.toJson).array.toJson;

        auto responsedata = Json.emptyObject.set("count", apps.length).set("applications", arr);
        return successResponse("Applications retrieved", "Retrieved " ~ apps.length ~ " applications for tenant " ~ tenantId, 200, responsedata);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto tenantId = precheck.tenantId;
        auto body_ = req.json;

        RegisterAppRequest dto;
        dto.appName = body_["appName"].get!string;
        dto.displayName = body_["displayName"].get!string;
        dto.description = body_.getString("description");
        dto.category = body_.getString("category");
        dto.plan = safeEnum!AppPlan(body_, "plan", AppPlan.application);
        dto.providerSubaccountId = body_.getString("providerSubaccountId");
        dto.globalAccountId = body_.getString("globalAccountId");
        dto.xsuaaServiceInstanceId = body_.getString("xsuaaServiceInstanceId");
        dto.autoSubscribeGlobalAccounts = safeBool(body_, "autoSubscribeGlobalAccounts");
        if ("appUrls" in body_) {
            auto u = body_["appUrls"];
            dto.appUrls.onSubscriptionUrl = safeStr(u, "onSubscriptionUrl");
            dto.appUrls.onUnsubscriptionUrl = safeStr(u, "onUnsubscriptionUrl");
            dto.appUrls.onUpdateUrl = safeStr(u, "onUpdateUrl");
            dto.appUrls.getDependenciesUrl = safeStr(u, "getDependenciesUrl");
            dto.appUrls.appBaseUrl = safeStr(u, "appBaseUrl");
        }

        auto result = usecase.registerApplication(tenantId, dto);
        if (result.hasError)
            return errorResponse("Application registration failed", result.message, 400);

        auto responsedata = Json.emptyObject.set("id", result.id);
        return successResponse("Application registered", "Application registered with ID " ~ result.id, 201, responsedata);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = SaasApplicationId(precheck.id);
        auto app = usecase.getApplication(tenantId, id);
        if (app.isNull)
            return errorResponse("Application not found", "No application found with ID " ~ id, 404);

        auto responsedata = app.toJson;
        return successResponse("Application retrieved", "Retrieved application with ID " ~ id, 200, responsedata);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = SaasApplicationId(precheck.id);
        auto body_ = req.json;

        UpdateAppRequest dto;
        dto.displayName = body_.getString("displayName");
        dto.description = body_.getString("description");
        dto.category = body_.getString("category");
        dto.plan = safeEnum!AppPlan(body_, "plan", AppPlan.application);
        dto.autoSubscribeGlobalAccounts = safeBool(body_, "autoSubscribeGlobalAccounts");
        if ("appUrls" in body_) {
            auto u = body_["appUrls"];
            dto.appUrls.onSubscriptionUrl = safeStr(u, "onSubscriptionUrl");
            dto.appUrls.onUnsubscriptionUrl = safeStr(u, "onUnsubscriptionUrl");
            dto.appUrls.onUpdateUrl = safeStr(u, "onUpdateUrl");
            dto.appUrls.getDependenciesUrl = safeStr(u, "getDependenciesUrl");
            dto.appUrls.appBaseUrl = safeStr(u, "appBaseUrl");
        }

        auto result = usecase.updateApplication(tenantId, id, dto);
        if (result.hasError)
            return errorResponse("Application update failed", result.message, 404);

        auto responsedata = Json.emptyObject.set("id", result.id);
        return successResponse("Application updated", "Updated application with ID " ~ result.id, 200, responsedata);

    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = SaasApplicationId(precheck.id);
        auto result = usecase.deregisterApplication(tenantId, id);
        if (result.hasError)
            return errorResponse("Application deregistration failed", result.message, 404);

        return successResponse("Application deregistered", "Deregistered application with ID " ~ id, 200, Json
                .emptyObject);
    }

    // -----------------------------------------------------------------------
    // JSON helpers
    // -----------------------------------------------------------------------

    private string safeStr(Json obj, string key) {
        if ((key in obj) !is null && obj[key].isString)
            return obj[key].get!string;
        return "";
    }

    private bool safeBool(Json obj, string key) {
        if ((key in obj) !is null && obj[key].isBoolean_)
            return obj[key].get!bool;
        return false;
    }

    private E safeEnum(E)(Json obj, string key, E default_) {
        if ((key in obj) !is null && obj[key].isString) {
            try {
                return obj[key].get!string
                    .to!E;
            } catch (Exception) {
            }
        }
        return default_;
    }
}
