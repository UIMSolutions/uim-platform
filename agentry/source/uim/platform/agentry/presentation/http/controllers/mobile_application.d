/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.mobile_application;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class MobileApplicationController : PlatformController {
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

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listMobileApplications(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Mobile application list retrieved successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = MobileApplicationId(extractIdFromPath(path));
            auto e = usecase.getMobileApplication(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Mobile application not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            MobileApplicationDTO dto;
            dto.mobileApplicationId = MobileApplicationId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.iconUrl = j.getString("iconUrl");
            dto.category = j.getString("category");
            dto.vendor = j.getString("vendor");
            dto.contactEmail = j.getString("contactEmail");
            dto.backendSystemId = j.getString("backendSystemId");
            dto.offlineCapable = j.getBool("offlineCapable");
            dto.pushNotificationsEnabled = j.getBool("pushNotificationsEnabled");
            dto.minOsVersion = j.getString("minOsVersion");
            dto.packageName = j.getString("packageName");

            auto result = usecase.createMobileApplication(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Mobile application created successfully");
            res.writeJsonBody(resp, 201);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            MobileApplicationDTO dto;
            dto.mobileApplicationId = MobileApplicationId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.iconUrl = j.getString("iconUrl");
            dto.category = j.getString("category");
            dto.vendor = j.getString("vendor");
            dto.contactEmail = j.getString("contactEmail");
            dto.minOsVersion = j.getString("minOsVersion");

            auto result = usecase.updateMobileApplication(dto);
            if (!result.success) { writeError(res, 404, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Mobile application updated successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = MobileApplicationId(extractIdFromPath(path));
            auto result = usecase.deleteMobileApplication(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Mobile application deleted successfully"), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
