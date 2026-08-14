/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.presentation.http.controllers.warehouse_order;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
class WarehouseOrderController : ManageHttpController {
private:
  ManageWarehouseOrdersUseCase _useCase;

public:
  this(ManageWarehouseOrdersUseCase useCase) {
    super("/api/v1/warehouse-orders");
    _useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get(basePath, &listHandler);
    router.post(basePath, &createHandler);
    router.get(basePath ~ "/*", &getHandler);
    router.put(basePath ~ "/*", &updateHandler);
    router.delete_(basePath ~ "/*", &deleteHandler);
  }

protected:
  override Json listHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto items = _useCase.listWarehouseOrders(tenantId);
    import std.algorithm : map;
    
    return jsonArray(items.map!(wo => wo.toJson).array);
  }

  override Json createHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto body_ = req.json;
    CreateWarehouseOrderRequest dto;
    dto.orderNumber = body_.getString("orderNumber");
    dto.description = body_.getString("description");
    dto.deliveryId = body_.getString("deliveryId");
    dto.warehouseId = body_.getString("warehouseId");
    dto.assignedTo = body_.getString("assignedTo");
    dto.dueAt = jsonInt(body_, "dueAt");
    auto result = _useCase.createWarehouseOrder(tenantId, dto);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError(result.message);
    }
    res.statusCode = cast(int) HTTPStatus.created;
    return Json(["id": Json(result.id), "statusCode": Json(201)]);
  }

  override Json getHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto id = WarehouseOrderId(extractIdFromPath(req.requestPath.to!string));
    auto wo = _useCase.getWarehouseOrder(tenantId, id);
    if (wo.isNull) {
      res.statusCode = cast(int) HTTPStatus.notFound;
      return writeError("Warehouse order not found");
    }
    return wo.toJson;
  }

  override Json updateHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto id = WarehouseOrderId(extractIdFromPath(req.requestPath.to!string));
    auto body_ = req.json;
    UpdateWarehouseOrderRequest dto;
    dto.description = body_.getString("description");
    dto.status = body_.getString("status");
    dto.assignedTo = body_.getString("assignedTo");
    dto.dueAt = jsonInt(body_, "dueAt");
    auto result = _useCase.updateWarehouseOrder(tenantId, id, dto);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError(result.message);
    }
    return Json(["id": Json(result.id), "statusCode": Json(200)]);
  }

  override Json deleteHandler(HTTPServerRequest req ) {
    auto tenantId = getTenantId(req);
    auto id = WarehouseOrderId(extractIdFromPath(req.requestPath.to!string));
    auto result = _useCase.deleteWarehouseOrder(tenantId, id);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.notFound;
      return writeError(result.message);
    }
    res.statusCode = cast(int) HTTPStatus.noContent;
    return Json(["statusCode": Json(204)]);
  }
}
