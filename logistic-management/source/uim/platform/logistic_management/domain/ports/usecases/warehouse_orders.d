/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.ports.usecases.warehouse_orders;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
interface IManageWarehouseOrdersUseCase {

  CommandResult createWarehouseOrder(TenantId tenantId, CreateWarehouseOrderRequest req);

  CommandResult updateWarehouseOrder(TenantId tenantId, WarehouseOrderId id, UpdateWarehouseOrderRequest req);

  CommandResult deleteWarehouseOrder(TenantId tenantId, WarehouseOrderId id);

  WarehouseOrder getWarehouseOrder(TenantId tenantId, WarehouseOrderId id);

  WarehouseOrder[] listWarehouseOrders(TenantId tenantId);

  WarehouseOrder[] listByDelivery(TenantId tenantId, DeliveryId deliveryId);

  WarehouseOrder[] listByStatus(TenantId tenantId, WarehouseOrderStatus status);
  
}
