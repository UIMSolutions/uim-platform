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

    auto data = req.json;
    TransitionFreightOrderRequest dto;
    dto.status = data.getString("status");
    dto.statusMessage = data.getString("statusMessage");
    dto.actualDepartureAt = jsonInt(data, "actualDepartureAt");
    dto.actualArrivalAt = jsonInt(data, "actualArrivalAt");

    auto result = _useCase.transitionFreightOrder(tenantId, id, dto);
    if (!result.success) {
      return writeError(res, cast(int) HTTPStatus.badRequest, result.message);
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
    auto data = req.json;
    CreateFreightOrderRequest dto;
    dto.orderNumber = data.getString("orderNumber");
    dto.description = data.getString("description");
    dto.originName = data.getString("originName");
    dto.originAddress = data.getString("originAddress");
    dto.destinationName = data.getString("destinationName");
    dto.destinationAddress = data.getString("destinationAddress");
    dto.carrierId = data.getString("carrierId");
    dto.transportMode = data.getString("transportMode");
    dto.weightKg = data["weightKg"].isFloat ? data["weightKg"].get!double : 0.0;
    dto.volumeM3 = data["volumeM3"].isFloat ? data["volumeM3"].get!double : 0.0;
    dto.plannedDepartureAt = jsonInt(data, "plannedDepartureAt");
    dto.plannedArrivalAt = jsonInt(data, "plannedArrivalAt");
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
    auto data = req.json;
    UpdateFreightOrderRequest dto;
    dto.description = data.getString("description");
    dto.originName = data.getString("originName");
    dto.originAddress = data.getString("originAddress");
    dto.destinationName = data.getString("destinationName");
    dto.destinationAddress = data.getString("destinationAddress");
    dto.carrierId = data.getString("carrierId");
    dto.transportMode = data.getString("transportMode");
    dto.weightKg = data["weightKg"].isFloat ? data["weightKg"].get!double : 0.0;
    dto.volumeM3 = data["volumeM3"].isFloat ? data["volumeM3"].get!double : 0.0;
    dto.plannedDepartureAt = jsonInt(data, "plannedDepartureAt");
    dto.plannedArrivalAt = jsonInt(data, "plannedArrivalAt");
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
        // auto j = Json.emptyObject;
// 
        // j["id"]      = result.id;
        // j["message"] = "Feature flag state updated";
        // res.writeJsonBody(j, cast(int) HTTPStatus.ok);