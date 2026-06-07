/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.ports.repositories.warehouse_tasks;
import uim.platform.logistic_management;

// mixin(ShowModule!());

@safe:
interface WarehouseTaskRepository : ITenantRepository!(WarehouseTask, WarehouseTaskId) {
  WarehouseTask[] findByWarehouseOrder(TenantId tenantId, WarehouseOrderId orderId);
  WarehouseTask[] findByStatus(TenantId tenantId, WarehouseTaskStatus status);
  WarehouseTask[] findByTaskType(TenantId tenantId, WarehouseTaskType taskType);
  WarehouseTask[] findByAssignee(TenantId tenantId, string assignedTo);
  void removeByWarehouseOrder(TenantId tenantId, WarehouseOrderId orderId);
}
