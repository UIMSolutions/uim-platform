/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.ports.usecases.warehouse_tasks;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
interface IManageWarehouseTasksUseCase {

  UsecaseResult createWarehouseTask(TenantId tenantId, CreateWarehouseTaskRequest req);

  UsecaseResult confirmTask(TenantId tenantId, WarehouseTaskId id, ConfirmWarehouseTaskRequest req);

  UsecaseResult deleteWarehouseTask(TenantId tenantId, WarehouseTaskId id);

  WarehouseTask getWarehouseTask(TenantId tenantId, WarehouseTaskId id);

  WarehouseTask[] listWarehouseTasks(TenantId tenantId);

  WarehouseTask[] listByOrder(TenantId tenantId, WarehouseOrderId orderId);

  WarehouseTask[] listByStatus(TenantId tenantId, WarehouseTaskStatus status);

  WarehouseTask[] listByType(TenantId tenantId, WarehouseTaskType taskType);
  
}
