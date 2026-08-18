/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.presentation.http.controllers.shipment;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
class ShipmentController : ManageHttpController {
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
  override Json listHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto items = _useCase.listShipments(tenantId);
    import std.algorithm : map;
    
    return jsonArray(items.map!(s => s.toJson).array);
  }

  override Json createHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto data = req.json;
    CreateShipmentRequest dto;
    dto.shipmentNumber = data.getString("shipmentNumber");
    dto.description = data.getString("description");
    dto.direction = data.getString("direction");
    dto.freightOrderId = data.getString("freightOrderId");
    dto.warehouseId = data.getString("warehouseId");
    dto.partnerId = data.getString("partnerId");
    dto.partnerName = data.getString("partnerName");
    dto.trackingNumber = data.getString("trackingNumber");
    dto.plannedDate = jsonInt(data, "plannedDate");
    auto result = _useCase.createShipment(tenantId, dto);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError(result.message);
    }
    res.statusCode = cast(int) HTTPStatus.created;
    return Json(["id": Json(result.id), "statusCode": Json(201)]);
  }

  override Json getHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto id = ShipmentId(extractIdFromPath(req.requestPath.to!string));
    auto s = _useCase.getShipment(tenantId, id);
    if (s.isNull) {
      res.statusCode = cast(int) HTTPStatus.notFound;
      return writeError("Shipment not found");
    }
    return s.toJson;
  }

  override Json updateHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto id = ShipmentId(extractIdFromPath(req.requestPath.to!string));
    auto data = req.json;
    UpdateShipmentRequest dto;
    dto.description = data.getString("description");
    dto.status = data.getString("status");
    dto.trackingNumber = data.getString("trackingNumber");
    dto.actualDate = jsonInt(data, "actualDate");
    auto result = _useCase.updateShipment(tenantId, id, dto);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError(result.message);
    }
    return Json(["id": Json(result.id), "statusCode": Json(200)]);
  }

  override Json deleteHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto id = ShipmentId(extractIdFromPath(req.requestPath.to!string));
    if (id.isNull) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError("Invalid shipment ID");
    }
    
    auto result = _useCase.deleteShipment(tenantId, id);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.notFound;
      return writeError(result.message);
    }
    res.statusCode = cast(int) HTTPStatus.noContent;
    return Json(["statusCode": Json(204)]);
  }
}
