/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.application.usecases.manage.warehouse_tasks;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
class ManageWarehouseTasksUseCase {
private:
  WarehouseTaskRepository _repo;
  LogisticsPlanner _planner;

public:
  this(WarehouseTaskRepository repo, LogisticsPlanner planner) {
    _repo = repo;
    _planner = planner;
  }

  CommandResult createWarehouseTask(TenantId tenantId, CreateWarehouseTaskRequest req) {
    if (req.taskNumber.length == 0)
      return CommandResult(false, "Task number is required");
    if (req.productId.length == 0)
      return CommandResult(false, "Product ID is required");

    
    WarehouseTask wt;
    wt.id = WarehouseTaskId(generateId());
    wt.tenantId = tenantId;
    wt.taskNumber = req.taskNumber;
    wt.warehouseOrderId = WarehouseOrderId(req.warehouseOrderId);
    wt.warehouseId = req.warehouseId;
    wt.sourceStorageBin = req.sourceStorageBin;
    wt.destinationStorageBin = req.destinationStorageBin;
    wt.productId = req.productId;
    wt.productDescription = req.productDescription;
    wt.quantity = req.quantity;
    wt.unit = req.unit;
    wt.assignedTo = req.assignedTo;
    wt.status = WarehouseTaskStatus.created;
    if (req.taskType.length > 0) {
      try { wt.taskType = req.taskType.to!WarehouseTaskType; } catch (Exception) {}
    }
    wt.createdAt = currentTimeMs();
    wt.updatedAt = wt.createdAt;
    _repo.save(wt);
    return CommandResult(true, "", wt.id.value);
  }

  CommandResult confirmTask(TenantId tenantId, WarehouseTaskId id, ConfirmWarehouseTaskRequest req) {
    auto wt = _repo.findById(tenantId, id);
    if (wt.isNull) return CommandResult(false, "Warehouse task not found");
    if (!_planner.canTransitionTask(wt.status, WarehouseTaskStatus.confirmed))
      return CommandResult(false, "Task cannot be confirmed from its current status");

    WarehouseTask updated;
    updated.id = wt.id;
    updated.tenantId = wt.tenantId;
    updated.taskNumber = wt.taskNumber;
    updated.taskType = wt.taskType;
    updated.warehouseOrderId = wt.warehouseOrderId;
    updated.warehouseId = wt.warehouseId;
    updated.sourceStorageBin = wt.sourceStorageBin;
    updated.destinationStorageBin = wt.destinationStorageBin;
    updated.productId = wt.productId;
    updated.productDescription = wt.productDescription;
    updated.quantity = wt.quantity;
    updated.unit = wt.unit;
    updated.assignedTo = req.assignedTo.length > 0 ? req.assignedTo : wt.assignedTo;
    updated.confirmedAt = req.confirmedAt > 0 ? req.confirmedAt : currentTimeMs();
    updated.status = WarehouseTaskStatus.confirmed;
    updated.createdAt = wt.createdAt;
    updated.updatedAt = currentTimeMs();
    _repo.save(updated);
    return CommandResult(true, "", id.value);
  }

  CommandResult deleteWarehouseTask(TenantId tenantId, WarehouseTaskId id) {
    auto wt = _repo.findById(tenantId, id);
    if (wt.isNull) return CommandResult(false, "Warehouse task not found");
    if (wt.status == WarehouseTaskStatus.confirmed)
      return CommandResult(false, "Cannot delete a confirmed warehouse task");
    _repo.remove(tenantId, id);
    return CommandResult(true);
  }

  WarehouseTask getWarehouseTask(TenantId tenantId, WarehouseTaskId id) {
    return _repo.findById(tenantId, id);
  }

  WarehouseTask[] listWarehouseTasks(TenantId tenantId) {
    return _repo.findAll(tenantId);
  }

  WarehouseTask[] listByOrder(TenantId tenantId, WarehouseOrderId orderId) {
    return _repo.findByWarehouseOrder(tenantId, orderId);
  }

  WarehouseTask[] listByStatus(TenantId tenantId, WarehouseTaskStatus status) {
    return _repo.findByStatus(tenantId, status);
  }

  WarehouseTask[] listByType(TenantId tenantId, WarehouseTaskType taskType) {
    return _repo.findByTaskType(tenantId, taskType);
  }
}
