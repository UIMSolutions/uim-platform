/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.presentation.http.controllers.delivery;
import uim.platform.logistic_management;

mixin(ShowModule!());

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
    super.registerRoutes(router);

    auto basePath = "/api/v1/deliveries";
    router.get(basePath, &listHandler);
    router.post(basePath, &createHandler);
    router.get(basePath ~ "/*", &getHandler);
    router.put(basePath ~ "/*", &updateHandler);
    router.delete_(basePath ~ "/*", &deleteHandler);
  }

protected:
  override Json listHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto items = _useCase.listDeliveries(tenantId);
    import std.algorithm : map;
    
    return jsonArray(items.map!(d => d.toJson).array);
  }

  override Json createHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto body_ = req.json;
    CreateDeliveryRequest dto;
    dto.deliveryNumber = body_.getString("deliveryNumber");
    dto.description = body_.getString("description");
    dto.direction = body_.getString("direction");
    dto.shipmentId = body_.getString("shipmentId");
    dto.warehouseId = body_.getString("warehouseId");
    dto.partnerId = body_.getString("partnerId");
    dto.partnerName = body_.getString("partnerName");
    dto.deliveryAddress = body_.getString("deliveryAddress");
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

  override Json getHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto id = DeliveryId(extractIdFromPath(req.requestPath.to!string));
    auto d = _useCase.getDelivery(tenantId, id);
    if (d.isNull) {
      res.statusCode = cast(int) HTTPStatus.notFound;
      return writeError("Delivery not found");
    }
    return d.toJson;
  }

  override Json updateHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto id = DeliveryId(extractIdFromPath(req.requestPath.to!string));
    auto body_ = req.json;
    UpdateDeliveryRequest dto;
    dto.description = body_.getString("description");
    dto.status = body_.getString("status");
    dto.deliveryAddress = body_.getString("deliveryAddress");
    dto.actualDate = jsonInt(body_, "actualDate");
    auto result = _useCase.updateDeliveryStatus(tenantId, id, dto);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError(result.message);
    }
    return Json(["id": Json(result.id), "statusCode": Json(200)]);
  }

  override Json deleteHandler(HTTPServerRequest req) {
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
