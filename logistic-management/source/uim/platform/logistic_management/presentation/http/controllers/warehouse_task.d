/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.presentation.http.controllers.warehouse_task;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
class WarehouseTaskController : ManageHttpController {
private:
  ManageWarehouseTasksUseCase _useCase;

public:
  this(ManageWarehouseTasksUseCase useCase) {
    super("/api/v1/warehouse-tasks");
    _useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get(basePath, &listHandler);
    router.post(basePath, &createHandler);
    router.get(basePath ~ "/*", &getHandler);
    router.put(basePath ~ "/*", &updateHandler);
    router.delete_(basePath ~ "/*", &deleteHandler);
    router.post(basePath ~ "/*/confirm", &confirmHandler);
  }

  void confirmHandler(HTTPServerRequest req) @safe {
    auto tenantId = getTenantId(req);
    auto rawPath = req.requestPath.to!string;
    import std.string : lastIndexOf;
    auto endIdx = rawPath.lastIndexOf("/confirm");
    auto idStr = rawPath[0 .. endIdx];
    auto slashIdx = idStr.lastIndexOf('/');
    auto id = WarehouseTaskId(idStr[slashIdx + 1 .. $]);

    auto body_ = req.json;
    ConfirmWarehouseTaskRequest dto;
    dto.assignedTo = body_.getString("assignedTo");
    dto.confirmedAt = jsonInt(body_, "confirmedAt");

    auto result = _useCase.confirmTask(tenantId, id, dto);
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
    auto items = _useCase.listWarehouseTasks(tenantId);
    import std.algorithm : map;
    
    return jsonArray(items.map!(t => t.toJson).array);
  }

  override Json createHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto body_ = req.json;
    CreateWarehouseTaskRequest dto;
    dto.taskNumber = body_.getString("taskNumber");
    dto.taskType = body_.getString("taskType");
    dto.warehouseOrderId = body_.getString("warehouseOrderId");
    dto.warehouseId = body_.getString("warehouseId");
    dto.sourceStorageBin = body_.getString("sourceStorageBin");
    dto.destinationStorageBin = body_.getString("destinationStorageBin");
    dto.productId = body_.getString("productId");
    dto.productDescription = body_.getString("productDescription");
    dto.quantity = body_["quantity"].isFloat ? body_["quantity"].get!double : 0.0;
    dto.unit = body_.getString("unit");
    dto.assignedTo = body_.getString("assignedTo");
    auto result = _useCase.createWarehouseTask(tenantId, dto);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError(result.message);
    }
    res.statusCode = cast(int) HTTPStatus.created;
    return Json(["id": Json(result.id), "statusCode": Json(201)]);
  }

  override Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = getTenantId(req);
    auto id = WarehouseTaskId(extractIdFromPath(req.requestPath.to!string));
    if (id.isNull) 
    
    auto wt = _useCase.getWarehouseTask(tenantId, id);
    if (wt.isNull) 
      return errorResponse("Warehouse task not found", 404);
    
    return wt.toJson;
  }

  override Json updateHandler(HTTPServerRequest req) {
    // Warehouse tasks are updated via confirm endpoint; this handles re-assignment only
    res.statusCode = cast(int) HTTPStatus.methodNotAllowed;
    return writeError("Use POST /confirm to update warehouse task status");
  }

  override Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;
      
    auto tenantId = getTenantId(req);
    auto id = WarehouseTaskId(extractIdFromPath(req.requestPath.to!string));
    if (id.isNull) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError("Invalid warehouse task ID");
    }
    auto result = _useCase.deleteWarehouseTask(tenantId, id);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.notFound;
      return writeError(result.message);
    }
    res.statusCode = cast(int) HTTPStatus.noContent;
    return Json(["statusCode": Json(204)]);
  }
}
