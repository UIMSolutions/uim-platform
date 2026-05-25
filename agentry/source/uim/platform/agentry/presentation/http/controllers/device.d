/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.device;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class DeviceController : PlatformController {
    private ManageDevicesUseCase usecase;

    this(ManageDevicesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/agentry/devices", &handleList);
        router.get("/api/v1/agentry/devices/*", &handleGet);
        router.post("/api/v1/agentry/devices", &handleCreate);
        router.put("/api/v1/agentry/devices/*", &handleUpdate);
        router.delete_("/api/v1/agentry/devices/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listDevices(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Device list retrieved successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DeviceId(extractIdFromPath(path));
            auto e = usecase.getDevice(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Device not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            DeviceDTO dto;
            dto.deviceId = DeviceId(j.getString("id"));
            dto.mobileApplicationId = MobileApplicationId(j.getString("mobileApplicationId"));
            dto.tenantId = tenantId;
            dto.deviceName = j.getString("deviceName");
            dto.deviceModel = j.getString("deviceModel");
            dto.manufacturer = j.getString("manufacturer");
            dto.osVersion = j.getString("osVersion");
            dto.appVersionInstalled = j.getString("appVersionInstalled");
            dto.pushToken = j.getString("pushToken");
            dto.userId = j.getString("userId");
            dto.userEmail = j.getString("userEmail");
            dto.groupName = j.getString("groupName");
            dto.isManaged = j.getBool("isManaged");
            dto.mdmDeviceId = j.getString("mdmDeviceId");

            auto result = usecase.enrollDevice(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Device enrolled successfully");
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
            DeviceDTO dto;
            dto.deviceId = DeviceId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.osVersion = j.getString("osVersion");
            dto.appVersionInstalled = j.getString("appVersionInstalled");
            dto.groupName = j.getString("groupName");
            dto.pushToken = j.getString("pushToken");

            auto result = usecase.updateDevice(dto);
            if (!result.success) { writeError(res, 404, result.message); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Device updated successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = DeviceId(extractIdFromPath(path));
            auto result = usecase.removeDevice(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Device removed successfully"), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
