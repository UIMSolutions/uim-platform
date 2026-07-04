/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.ports.repositories.warehouse_orders;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
interface WarehouseOrderRepository : ITenantRepository!(WarehouseOrder, WarehouseOrderId) {
  WarehouseOrder[] findByDelivery(TenantId tenantId, DeliveryId deliveryId);
  WarehouseOrder[] findByStatus(TenantId tenantId, WarehouseOrderStatus status);
  WarehouseOrder[] findByWarehouse(TenantId tenantId, string warehouseId);
  void removeByDelivery(TenantId tenantId, DeliveryId deliveryId);
}
