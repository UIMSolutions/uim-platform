/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.presentation.http.controllers.delivery;
import uim.platform.logistic_management;

// mixin(ShowModule!());

@safe:
class DeliveryController : ManageHttpController {
private:
  ManageDeliveriesUseCase _useCase;

public:
  this(ManageDeliveriesUseCase useCase) {
    super("/api/v1/deliveries");
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
    auto items = _useCase.listDeliveries(tenantId);
    import std.algorithm : map;
    import std.array : array;
    return jsonArray(items.map!(d => d.toJson).array);
  }

  override Json createHandler(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = getTenantId(req);
    auto body_ = req.json;
    CreateDeliveryRequest dto;
    dto.deliveryNumber = jsonStr(body_, "deliveryNumber");
    dto.description = jsonStr(body_, "description");
    dto.direction = jsonStr(body_, "direction");
    dto.shipmentId = jsonStr(body_, "shipmentId");
    dto.warehouseId = jsonStr(body_, "warehouseId");
    dto.partnerId = jsonStr(body_, "partnerId");
    dto.partnerName = jsonStr(body_, "partnerName");
    dto.deliveryAddress = jsonStr(body_, "deliveryAddress");
    dto.plannedDate = jsonInt(body_, "plannedDate");
    auto itemsJson = body_["items"];
    if (itemsJson.isArray) {
      foreach (ij; itemsJson.byValue) {
        DeliveryItemRequest ir;
        ir.itemNumber = jsonStr(ij, "itemNumber");
        ir.productId = jsonStr(ij, "productId");
        ir.productDescription = jsonStr(ij, "productDescription");
        ir.quantity = ij["quantity"].isFloat ? ij["quantity"].get!double : 0.0;
        ir.unit = jsonStr(ij, "unit");
        ir.weightKg = ij["weightKg"].isFloat ? ij["weightKg"].get!double : 0.0;
        ir.volumeM3 = ij["volumeM3"].isFloat ? ij["volumeM3"].get!double : 0.0;
        dto.items ~= ir;
      }
    }
    auto result = _useCase.createDelivery(tenantId, dto);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError(result.message);
    }
    res.statusCode = cast(int) HTTPStatus.created;
    return Json(["id": Json(result.id), "statusCode": Json(201)]);
  }

  override Json getHandler(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = getTenantId(req);
    auto id = DeliveryId(extractIdFromPath(req.requestPath.to!string));
    auto d = _useCase.getDelivery(tenantId, id);
    if (d.isNull) {
      res.statusCode = cast(int) HTTPStatus.notFound;
      return writeError("Delivery not found");
    }
    return d.toJson;
  }

  override Json updateHandler(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = getTenantId(req);
    auto id = DeliveryId(extractIdFromPath(req.requestPath.to!string));
    auto body_ = req.json;
    UpdateDeliveryRequest dto;
    dto.description = jsonStr(body_, "description");
    dto.status = jsonStr(body_, "status");
    dto.deliveryAddress = jsonStr(body_, "deliveryAddress");
    dto.actualDate = jsonInt(body_, "actualDate");
    auto result = _useCase.updateDeliveryStatus(tenantId, id, dto);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError(result.message);
    }
    return Json(["id": Json(result.id), "statusCode": Json(200)]);
  }

  override Json deleteHandler(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = getTenantId(req);
    auto id = DeliveryId(extractIdFromPath(req.requestPath.to!string));
    auto result = _useCase.deleteDelivery(tenantId, id);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.notFound;
      return writeError(result.message);
    }
    res.statusCode = cast(int) HTTPStatus.noContent;
    return Json(["statusCode": Json(204)]);
  }
}
