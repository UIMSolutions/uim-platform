/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.infrastructure.persistence.memory.warehouse_tasks;
import uim.platform.logistic_management;
import std.algorithm : filter, each;
import std.array : array;

// mixin(ShowModule!());

@safe:
class MemoryWarehouseTaskRepository : TentRepository!(WarehouseTask, WarehouseTaskId), WarehouseTaskRepository {
  override WarehouseTask[] findByWarehouseOrder(TenantId tenantId, WarehouseOrderId orderId) {
    return findAll(tenantId).filter!(t => t.warehouseOrderId.value == orderId.value).array;
  }

  override WarehouseTask[] findByStatus(TenantId tenantId, WarehouseTaskStatus status) {
    return findAll(tenantId).filter!(t => t.status == status).array;
  }

  override WarehouseTask[] findByTaskType(TenantId tenantId, WarehouseTaskType taskType) {
    return findAll(tenantId).filter!(t => t.taskType == taskType).array;
  }

  override WarehouseTask[] findByAssignee(TenantId tenantId, string assignedTo) {
    return findAll(tenantId).filter!(t => t.assignedTo == assignedTo).array;
  }

  override void removeByWarehouseOrder(TenantId tenantId, WarehouseOrderId orderId) {
    auto toRemove = findByWarehouseOrder(tenantId, orderId);
    toRemove.each!(t => remove(tenantId, t.id));
  }
}
