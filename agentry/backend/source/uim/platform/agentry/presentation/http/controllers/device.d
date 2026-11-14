/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.device;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// REST adapter for devices:
///   GET/POST {base}/devices   GET/PUT/DELETE {base}/devices/:id
class DeviceController : ManageHttpController {
  protected IManageDevicesUseCase usecase;
  protected string basePath;

  this(IManageDevicesUseCase usecase, string apiPath = "/api/v1/agentry") {
    this.usecase = usecase;
    this.basePath = apiPath.stripRight("/") ~ "/devices";
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get(basePath, &handleList);
    router.get(basePath ~ "/*", &handleGet);
    router.post(basePath, &handleCreate);
    router.put(basePath ~ "/*", &handleUpdate);
    router.delete_(basePath ~ "/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto items = usecase.listDevices(precheck.tenantId);
    auto resp = Json.emptyObject
      .set("count", items.length)
      .set("resources", items.map!(e => e.toJson()).array.toJson);
    return successResponse("Device list retrieved", "Retrieved", 200, resp);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    DeviceDTO dto;
    try
      readPayload(dto, precheck.data);
    catch (PayloadException e)
      return errorResponse(e.msg, 400);
    dto.tenantId = precheck.tenantId;
    dto.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.enrollDevice(dto);
    if (!result.isSuccess)
      return errorResponse(result.message, httpStatusOf(result));
    return successResponse(result.message, "Created", 201, Json.emptyObject.set("id", result.id));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = DeviceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid device ID", 400);
    auto entity = usecase.getDevice(precheck.tenantId, id);
    if (entity.isNull)
      return errorResponse("Device not found", 404);
    return successResponse("Device retrieved", "Retrieved", 200, entity.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = DeviceId(precheck.id);
    auto current = usecase.getDevice(precheck.tenantId, id);
    if (current.isNull)
      return errorResponse("Device not found", 404);

    // merge: start from the stored values, overlay the supplied ones
    auto dto = DeviceDTO.fromEntity(current);
    try
      readPayload(dto, precheck.data);
    catch (PayloadException e)
      return errorResponse(e.msg, 400);
    dto.deviceId = id;
    dto.tenantId = precheck.tenantId;
    dto.updatedBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.updateDevice(dto);
    if (!result.isSuccess)
      return errorResponse(result.message, httpStatusOf(result));
    return successResponse(result.message, "Updated", 200, Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = DeviceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid device ID", 400);
    auto result = usecase.removeDevice(precheck.tenantId, id);
    if (!result.isSuccess)
      return errorResponse(result.message, httpStatusOf(result));
    return successResponse(result.message, "Deleted", 200, Json.emptyObject.set("id", id.value));
  }
}
