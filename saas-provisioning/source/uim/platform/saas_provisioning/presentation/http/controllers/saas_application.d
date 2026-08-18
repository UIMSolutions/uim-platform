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
        auto data = req.json;

        RegisterAppRequest dto;
        dto.appName = data["appName"].get!string;
        dto.displayName = data["displayName"].get!string;
        dto.description = data.getString("description");
        dto.category = data.getString("category");
        dto.plan = safeEnum!AppPlan(data, "plan", AppPlan.application);
        dto.providerSubaccountId = data.getString("providerSubaccountId");
        dto.globalAccountId = data.getString("globalAccountId");
        dto.xsuaaServiceInstanceId = data.getString("xsuaaServiceInstanceId");
        dto.autoSubscribeGlobalAccounts = safeBool(data, "autoSubscribeGlobalAccounts");
        if ("appUrls" in data) {
            auto u = data["appUrls"];
            dto.appUrls.onSubscriptionUrl = u.getString("onSubscriptionUrl");
            dto.appUrls.onUnsubscriptionUrl = u.getString("onUnsubscriptionUrl");
            dto.appUrls.onUpdateUrl = u.getString("onUpdateUrl");
            dto.appUrls.getDependenciesUrl = u.getString("getDependenciesUrl");
            dto.appUrls.appBaseUrl = u.getString("appBaseUrl");
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
        if (id.isNull)
            return errorResponse("Invalid application ID", "Invalid application ID: " ~ precheck.id.value, 400);

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
        if (id.isNull)
            return errorResponse("Invalid application ID", "Invalid application ID: " ~ precheck.id.value, 400);

        auto data = req.json;

        UpdateAppRequest dto;
        dto.displayName = data.getString("displayName");
        dto.description = data.getString("description");
        dto.category = data.getString("category");
        dto.plan = safeEnum!AppPlan(data, "plan", AppPlan.application);
        dto.autoSubscribeGlobalAccounts = safeBool(data, "autoSubscribeGlobalAccounts");
        if ("appUrls" in data) {
            auto u = data["appUrls"];
            dto.appUrls.onSubscriptionUrl = u.getString("onSubscriptionUrl");
            dto.appUrls.onUnsubscriptionUrl = u.getString("onUnsubscriptionUrl");
            dto.appUrls.onUpdateUrl = u.getString("onUpdateUrl");
            dto.appUrls.getDependenciesUrl = u.getString("getDependenciesUrl");
            dto.appUrls.appBaseUrl = u.getString("appBaseUrl");
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
        if (id.isNull)
            return errorResponse("Invalid application ID", "Invalid application ID: " ~ precheck.id.value, 400);
            
        auto result = usecase.deregisterApplication(tenantId, id);
        if (result.hasError)
            return errorResponse("Application deregistration failed", result.message, 404);

        return successResponse("Application deregistered", "Deregistered application with ID " ~ id, 200, Json
                .emptyObject);
    }

}
