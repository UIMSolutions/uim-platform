/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.mobile_application;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class MobileApplicationController : ManageController {
    private ManageMobileApplicationsUseCase usecase;

    this(ManageMobileApplicationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/agentry/mobile-applications", &handleList);
        router.get("/api/v1/agentry/mobile-applications/*", &handleGet);
        router.post("/api/v1/agentry/mobile-applications", &handleCreate);
        router.put("/api/v1/agentry/mobile-applications/*", &handleUpdate);
        router.delete_("/api/v1/agentry/mobile-applications/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listMobileApplications(tenantId);
        auto jarr = items.map!(e => e.toJson()).array.toJson;
        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr);

        return successResponse("Mobile application list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = MobileApplicationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid mobile application ID", 400);

        auto e = usecase.getMobileApplication(tenantId, id);
        if (job.isNull)
            return errorResponse("Mobile application not found", 404);

        auto responseData = e.toJson();
        return successResponse("Mobile application retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        MobileApplicationDTO dto;
        dto.applicationId = MobileApplicationId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.iconUrl = data.getString("iconUrl");
        dto.category = data.getString("category");
        dto.vendor = data.getString("vendor");
        dto.contactEmail = data.getString("contactEmail");
        dto.backendSystemId = data.getString("backendSystemId");
        dto.offlineCapable = data.getBoolean("offlineCapable");
        dto.pushNotificationsEnabled = data.getBoolean("pushNotificationsEnabled");
        dto.minOsVersion = data.getString("minOsVersion");
        dto.packageName = data.getString("packageName");

        auto result = usecase.createMobileApplication(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Mobile application created successfully", "Created", 201, responseData);

    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = MobileApplicationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid mobile application ID", 400);

        MobileApplicationDTO dto;
        dto.mobileApplicationId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.iconUrl = data.getString("iconUrl");
        dto.category = data.getString("category");
        dto.vendor = data.getString("vendor");
        dto.contactEmail = data.getString("contactEmail");
        dto.minOsVersion = data.getString("minOsVersion");

        auto result = usecase.updateMobileApplication(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", id);
        return successResponse("Mobile application updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = MobileApplicationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid mobile application ID", 400);

        auto result = usecase.deleteMobileApplication(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Mobile application deleted successfully", "Deleted", 200, responseData);
    }
