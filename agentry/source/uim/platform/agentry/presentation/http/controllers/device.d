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
        dto.deviceId = DeviceId(precheck.id);
        dto.mobileApplicationId = MobileApplicationId(data.getString("mobileApplicationId"));
        dto.tenantId = tenantId;
        dto.deviceName = data.getString("deviceName");
        dto.deviceModel = data.getString("deviceModel");
        dto.manufacturer = data.getString("manufacturer");
        dto.osVersion = data.getString("osVersion");
        dto.appVersionInstalled = data.getString("appVersionInstalled");
        dto.pushToken = data.getString("pushToken");
        dto.userId = data.getString("userId");
        dto.userEmail = data.getString("userEmail");
        dto.groupName = data.getString("groupName");
        dto.isManaged = j.getBoolean("isManaged");
        dto.mdmDeviceId = data.getString("mdmDeviceId");

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
        auto id = DeviceId(precheck.id);
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
        dto.deviceId = DeviceId(precheck.id);
        dto.tenantId = tenantId;
        dto.osVersion = data.getString("osVersion");
        dto.appVersionInstalled = data.getString("appVersionInstalled");
        dto.groupName = data.getString("groupName");
        dto.pushToken = data.getString("pushToken");

        auto result = usecase.updateDevice(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("id", result.id);

        return successResponse("Device updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = DeviceId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid device ID", 400);

        auto result = usecase.removeDevice(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        auto resp = Json.emptyObject
            .set("id", id);

        return successResponse("Device removed successfully", "Deleted", 200, resp);
    }
}
