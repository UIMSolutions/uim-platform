/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.presentation.http.controllers.freight_order;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
class FreightOrderController : ManageHttpController {
private:
  ManageFreightOrdersUseCase _useCase;

public:
  this(ManageFreightOrdersUseCase useCase) {
    super("/api/v1/freight-orders");
    _useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get(basePath, &listHandler);
    router.post(basePath, &createHandler);
    router.get(basePath ~ "/*", &getHandler);
    router.put(basePath ~ "/*", &updateHandler);
    router.delete_(basePath ~ "/*", &deleteHandler);
    router.post(basePath ~ "/*/transition", &transitionHandler);
  }

  void transitionHandler(HTTPServerRequest req) @safe {
    auto tenantId = getTenantId(req);
    auto rawPath = req.requestPath.to!string;
    // Extract ID between last two segments: /api/v1/freight-orders/{id}/transition
    import std.string : lastIndexOf;
    auto endIdx = rawPath.lastIndexOf("/transition");
    auto idStr = rawPath[0 .. endIdx];
    import std.algorithm : findSplitBefore;
    auto slashIdx = idStr.lastIndexOf('/');
    auto id = FreightOrderId(idStr[slashIdx + 1 .. $]);

    auto body_ = req.json;
    TransitionFreightOrderRequest dto;
    dto.status = body_.getString("status");
    dto.statusMessage = body_.getString("statusMessage");
    dto.actualDepartureAt = jsonInt(body_, "actualDepartureAt");
    dto.actualArrivalAt = jsonInt(body_, "actualArrivalAt");

    auto result = _useCase.transitionFreightOrder(tenantId, id, dto);
    if (!result.success) {
      res.writeBody(`{"error":"` ~ result.message ~ `","statusCode":400}`,
          cast(int) HTTPStatus.badRequest, "application/json");
      return;
    }
    res.writeJsonBody(Json(["id": Json(result.id), "statusCode": Json(200)]));
  }

protected:
  override Json listHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto orders = _useCase.listFreightOrders(tenantId);
    import std.algorithm : map;
    
    return jsonArray(orders.map!(o => o.toJson).array);
  }

  override Json createHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto body_ = req.json;
    CreateFreightOrderRequest dto;
    dto.orderNumber = body_.getString("orderNumber");
    dto.description = body_.getString("description");
    dto.originName = body_.getString("originName");
    dto.originAddress = body_.getString("originAddress");
    dto.destinationName = body_.getString("destinationName");
    dto.destinationAddress = body_.getString("destinationAddress");
    dto.carrierId = body_.getString("carrierId");
    dto.transportMode = body_.getString("transportMode");
    dto.weightKg = body_["weightKg"].isFloat ? body_["weightKg"].get!double : 0.0;
    dto.volumeM3 = body_["volumeM3"].isFloat ? body_["volumeM3"].get!double : 0.0;
    dto.plannedDepartureAt = jsonInt(body_, "plannedDepartureAt");
    dto.plannedArrivalAt = jsonInt(body_, "plannedArrivalAt");
    auto result = _useCase.createFreightOrder(tenantId, dto);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError(result.message);
    }
    res.statusCode = cast(int) HTTPStatus.created;
    return Json(["id": Json(result.id), "statusCode": Json(201)]);
  }

  override Json getHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto id = FreightOrderId(extractIdFromPath(req.requestPath.to!string));
    auto fo = _useCase.getFreightOrder(tenantId, id);
    if (fo.isNull)
      return errorResponse("Freight order not found", 404);

    return successResponse("Freight order retrieved successfully", "OK", 200, fo.toJson());
  }

  override Json updateHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto id = FreightOrderId(extractIdFromPath(req.requestPath.to!string));
    auto body_ = req.json;
    UpdateFreightOrderRequest dto;
    dto.description = body_.getString("description");
    dto.originName = body_.getString("originName");
    dto.originAddress = body_.getString("originAddress");
    dto.destinationName = body_.getString("destinationName");
    dto.destinationAddress = body_.getString("destinationAddress");
    dto.carrierId = body_.getString("carrierId");
    dto.transportMode = body_.getString("transportMode");
    dto.weightKg = body_["weightKg"].isFloat ? body_["weightKg"].get!double : 0.0;
    dto.volumeM3 = body_["volumeM3"].isFloat ? body_["volumeM3"].get!double : 0.0;
    dto.plannedDepartureAt = jsonInt(body_, "plannedDepartureAt");
    dto.plannedArrivalAt = jsonInt(body_, "plannedArrivalAt");
    auto result = _useCase.updateFreightOrder(tenantId, id, dto);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Freight order updated successfully", "OK", 200, Json(["id": Json(result.id)]));
  }

  override Json deleteHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto id = FreightOrderId(extractIdFromPath(req.requestPath.to!string));
    if (id.isNull)
      return errorResponse("Invalid freight order ID", 400);
      
    auto result = _useCase.deleteFreightOrder(tenantId, id);
    if (result.hasError) 
      return errorResponse(result.message, 404);
  
    return successResponse("Freight order deleted successfully", "OK", 200, Json(["id": Json(result.id)]));
  }
}
