/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.infrastructure.persistence.repositories.warehouse_tasks;
import uim.platform.logistic_management;
import std.algorithm : filter, each;


mixin(ShowModule!());

@safe:
class WarehouseTaskRepository : TenantRepository!(WarehouseTask, WarehouseTaskId), IWarehouseTaskRepository {

  size_t countByWarehouseOrder(TenantId tenantId, WarehouseOrderId orderId) {
    return findByWarehouseOrder(tenantId, orderId).length;
  }

  WarehouseTask[] filterByWarehouseOrder(WarehouseTask[] tasks, WarehouseOrderId orderId) {
    return tasks.filter!(t => t.warehouseOrderId.value == orderId.value).array;
  }

  WarehouseTask[] findByWarehouseOrder(TenantId tenantId, WarehouseOrderId orderId) {
    return filterByWarehouseOrder(findByTenant(tenantId), orderId);
  }

  void removeByWarehouseOrder(TenantId tenantId, WarehouseOrderId orderId) {
    findByWarehouseOrder(tenantId, orderId).each!(t => remove(tenantId, t.id));
  }

  size_t countByStatus(TenantId tenantId, WarehouseTaskStatus status) {
    return findByStatus(tenantId, status).length;
  }

  WarehouseTask[] filterByStatus(WarehouseTask[] tasks, WarehouseTaskStatus status) {
    return tasks.filter!(t => t.status == status).array;
  }

  WarehouseTask[] findByStatus(TenantId tenantId, WarehouseTaskStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, WarehouseTaskStatus status) {
    findByStatus(tenantId, status).each!(t => remove(tenantId, t.id));
  }

  size_t countByTaskType(TenantId tenantId, WarehouseTaskType taskType) {
    return findByTaskType(tenantId, taskType).length;
  }

  WarehouseTask[] filterByTaskType(WarehouseTask[] tasks, WarehouseTaskType taskType) {
    return tasks.filter!(t => t.taskType == taskType).array;
  }

  WarehouseTask[] findByTaskType(TenantId tenantId, WarehouseTaskType taskType) {
    return filterByTaskType(findByTenant(tenantId), taskType).array;
  }

  void removeByTaskType(TenantId tenantId, WarehouseTaskType taskType) {
    findByTaskType(tenantId, taskType).each!(t => remove(tenantId, t.id));
  }

  size_t countByAssignee(TenantId tenantId, string assignedTo) {
    return findByAssignee(tenantId, assignedTo).length;
  }

  WarehouseTask[] filterByAssignee(WarehouseTask[] tasks, string assignedTo) {
    return tasks.filter!(t => t.assignedTo == assignedTo).array;
  }

  WarehouseTask[] findByAssignee(TenantId tenantId, string assignedTo) {
    return filterByAssignee(findByTenant(tenantId), assignedTo);
  }

  void removeByAssignee(TenantId tenantId, string assignedTo) {
    findByAssignee(tenantId, assignedTo).each!(t => remove(tenantId, t.id));
  }

}
