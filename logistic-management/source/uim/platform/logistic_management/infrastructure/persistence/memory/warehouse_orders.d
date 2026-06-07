/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.infrastructure.persistence.memory.warehouse_orders;
import uim.platform.logistic_management;
import std.algorithm : filter, each;
import std.array : array;

// mixin(ShowModule!());

@safe:
class MemoryWarehouseOrderRepository : TenantRepository!(WarehouseOrder, WarehouseOrderId), WarehouseOrderRepository {
  override WarehouseOrder[] findByDelivery(TenantId tenantId, DeliveryId deliveryId) {
    return findAll(tenantId).filter!(wo => wo.deliveryId.value == deliveryId.value).array;
  }

  override WarehouseOrder[] findByStatus(TenantId tenantId, WarehouseOrderStatus status) {
    return findAll(tenantId).filter!(wo => wo.status == status).array;
  }

  override WarehouseOrder[] findByWarehouse(TenantId tenantId, string warehouseId) {
    return findAll(tenantId).filter!(wo => wo.warehouseId == warehouseId).array;
  }

  override void removeByDelivery(TenantId tenantId, DeliveryId deliveryId) {
    auto toRemove = findByDelivery(tenantId, deliveryId);
    toRemove.each!(wo => remove(tenantId, wo.id));
  }
}
