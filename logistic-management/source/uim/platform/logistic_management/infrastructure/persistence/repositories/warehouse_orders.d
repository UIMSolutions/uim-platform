/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.infrastructure.persistence.repositories.warehouse_orders;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
class WarehouseOrderRepository : TenantRepository!(WarehouseOrder, WarehouseOrderId), IWarehouseOrderRepository {

  size_t countByDelivery(TenantId tenantId, DeliveryId deliveryId) {
    return findByDelivery(tenantId, deliveryId).length;
  }

  WarehouseOrder[] filterByDelivery(WarehouseOrder[] orders, DeliveryId deliveryId) {
    return orders.filter!(wo => wo.deliveryId.value == deliveryId.value).array;
  }

  WarehouseOrder[] findByDelivery(TenantId tenantId, DeliveryId deliveryId) {
    return filterByDelivery(findByTenant(tenantId), deliveryId);
  }

  void removeByDelivery(TenantId tenantId, DeliveryId deliveryId) {
    findByDelivery(tenantId, deliveryId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, WarehouseOrderStatus status) {
    return findByStatus(tenantId, status).length;
  }

  WarehouseOrder[] filterByStatus(WarehouseOrder[] orders, WarehouseOrderStatus status) {
    return orders.filter!(wo => wo.status == status).array;
  }

  WarehouseOrder[] findByStatus(TenantId tenantId, WarehouseOrderStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, WarehouseOrderStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

  size_t countByWarehouse(TenantId tenantId, string warehouseId) {
    return findByWarehouse(tenantId, warehouseId).length;
  }

  WarehouseOrder[] filterByWarehouse(WarehouseOrder[] orders, string warehouseId) {
    return orders.filter!(wo => wo.warehouseId == warehouseId).array;
  }

  WarehouseOrder[] findByWarehouse(TenantId tenantId, string warehouseId) {
    return filterByWarehouse(findByTenant(tenantId), warehouseId);
  }

  void removeByWarehouse(TenantId tenantId, string warehouseId) {
    findByWarehouse(tenantId, warehouseId).each!(e => remove(e));
  }
}
