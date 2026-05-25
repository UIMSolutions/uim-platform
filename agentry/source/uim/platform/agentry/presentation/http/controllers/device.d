/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.device;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class DeviceController : ManageController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listDevices(tenantId);
        auto jarr = items.map!(e => e.toJson()).array.toJson;
        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr);

        return successResponse("Device list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

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
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("id", result.id);

        return successResponse("Device enrolled successfully", "Created", 201, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = DeviceId(extractIdFromPath(path));
        if (id.isNull)
            return errorResponse("Invalid device ID", 400);

        auto e = usecase.getDevice(tenantId, id);
        if (e.isNull)
            return errorResponse("Device not found", 404);

        return successResponse("Device retrieved successfully", "Retrieved", 200, e.toJson);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

        DeviceDTO dto;
        dto.deviceId = DeviceId(extractIdFromPath(path));
        dto.tenantId = tenantId;
        dto.osVersion = j.getString("osVersion");
        dto.appVersionInstalled = j.getString("appVersionInstalled");
        dto.groupName = j.getString("groupName");
        dto.pushToken = j.getString("pushToken");

        auto result = usecase.updateDevice(dto);
        if (!result.success) {
            writeError(res, 404, result.message);
            return;
        }

        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Device updated successfully");
        res.writeJsonBody(resp, 200);
    }
 catch (Exception e) {
        writeError(res, 500, "Internal server error");
    }
}

override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
        auto tenantId = req.getTenantId;
        auto path = req.requestURI.to!string;
        auto id = DeviceId(extractIdFromPath(path));
        auto result = usecase.removeDevice(tenantId, id);
        if (!result.success) {
            writeError(res, 404, result.message);
            return;
        }
        res.writeJsonBody(Json.emptyObject.set("message", "Device removed successfully"), 200);
    } catch (Exception e) {
        writeError(res, 500, "Internal server error");
    }
}
}
