/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.presentation.http.controllers.shipment;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
class ShipmentController : ManageController {
private:
  ManageShipmentsUseCase _useCase;

public:
  this(ManageShipmentsUseCase useCase) {
    super("/api/v1/shipments");
    _useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get(basePath, &listHandler);
    router.post(basePath, &createHandler);
    router.get(basePath ~ "/*", &getHandler);
    router.put(basePath ~ "/*", &updateHandler);
    router.delete_(basePath ~ "/*", &deleteHandler);
  }

protected:
  override Json listHandler(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = getTenantId(req);
    auto items = _useCase.listShipments(tenantId);
    import std.algorithm : map;
    import std.array : array;
    return jsonArray(items.map!(s => s.toJson).array);
  }

  override Json createHandler(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = getTenantId(req);
    auto body_ = req.json;
    CreateShipmentRequest dto;
    dto.shipmentNumber = jsonStr(body_, "shipmentNumber");
    dto.description = jsonStr(body_, "description");
    dto.direction = jsonStr(body_, "direction");
    dto.freightOrderId = jsonStr(body_, "freightOrderId");
    dto.warehouseId = jsonStr(body_, "warehouseId");
    dto.partnerId = jsonStr(body_, "partnerId");
    dto.partnerName = jsonStr(body_, "partnerName");
    dto.trackingNumber = jsonStr(body_, "trackingNumber");
    dto.plannedDate = jsonInt(body_, "plannedDate");
    auto result = _useCase.createShipment(tenantId, dto);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError(result.message);
    }
    res.statusCode = cast(int) HTTPStatus.created;
    return Json(["id": Json(result.id), "statusCode": Json(201)]);
  }

  override Json getHandler(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = getTenantId(req);
    auto id = ShipmentId(extractIdFromPath(req.requestPath.to!string));
    auto s = _useCase.getShipment(tenantId, id);
    if (s == Shipment.init) {
      res.statusCode = cast(int) HTTPStatus.notFound;
      return writeError("Shipment not found");
    }
    return s.toJson;
  }

  override Json updateHandler(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = getTenantId(req);
    auto id = ShipmentId(extractIdFromPath(req.requestPath.to!string));
    auto body_ = req.json;
    UpdateShipmentRequest dto;
    dto.description = jsonStr(body_, "description");
    dto.status = jsonStr(body_, "status");
    dto.trackingNumber = jsonStr(body_, "trackingNumber");
    dto.actualDate = jsonInt(body_, "actualDate");
    auto result = _useCase.updateShipment(tenantId, id, dto);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError(result.message);
    }
    return Json(["id": Json(result.id), "statusCode": Json(200)]);
  }

  override Json deleteHandler(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = getTenantId(req);
    auto id = ShipmentId(extractIdFromPath(req.requestPath.to!string));
    auto result = _useCase.deleteShipment(tenantId, id);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.notFound;
      return writeError(result.message);
    }
    res.statusCode = cast(int) HTTPStatus.noContent;
    return Json(["statusCode": Json(204)]);
  }
}
