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
  WarehouseOrder[] findByDelivery(string tenantId, DeliveryId deliveryId);
  WarehouseOrder[] findByStatus(string tenantId, WarehouseOrderStatus status);
  WarehouseOrder[] findByWarehouse(string tenantId, string warehouseId);
  void removeByDelivery(string tenantId, DeliveryId deliveryId);
}
