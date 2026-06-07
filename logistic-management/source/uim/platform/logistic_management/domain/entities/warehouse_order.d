/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.entities.warehouse_order;
import uim.platform.logistic_management;

// mixin(ShowModule!());

@safe:
/// A warehouse order groups related warehouse tasks for a delivery or transfer.
struct WarehouseOrder {
  mixin TenantEntity!(WarehouseOrderId);

  string orderNumber;
  string description;
  WarehouseOrderStatus status = WarehouseOrderStatus.created;
  DeliveryId deliveryId;
  string warehouseId;
  string assignedTo;
  long dueAt;
  long createdAt;
  long updatedAt;

  Json toJson() const {
    return entityToJson
        .set("orderNumber", orderNumber)
        .set("description", description)
        .set("status", status.to!string)
        .set("deliveryId", deliveryId.value)
        .set("warehouseId", warehouseId)
        .set("assignedTo", assignedTo)
        .set("dueAt", Json(dueAt))
        .set("createdAt", Json(createdAt))
        .set("updatedAt", Json(updatedAt));
  }
}
