/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.entities.delivery;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
/// Line item within a delivery document.
struct DeliveryItem {
  string itemNumber;
  string productId;
  string productDescription;
  double quantity;
  string unit;
  double weightKg;
  double volumeM3;

  Json toJson() const {
    return Json.emptyObject
        .set("itemNumber", itemNumber)
        .set("productId", productId)
        .set("productDescription", productDescription)
        .set("quantity", Json(quantity))
        .set("unit", unit)
        .set("weightKg", Json(weightKg))
        .set("volumeM3", Json(volumeM3));
  }
}

/// An inbound or outbound delivery document with line items.
struct Delivery {
  mixin TenantEntity!(DeliveryId);

  string deliveryNumber;
  string description;
  LogisticsDirection direction = LogisticsDirection.outbound;
  DeliveryStatus status = DeliveryStatus.created;
  ShipmentId shipmentId;
  string warehouseId;
  string partnerId;
  string partnerName;
  string deliveryAddress;
  DeliveryItem[] items;
  long plannedDate;
  long actualDate;
  long createdAt;
  long updatedAt;

  Json toJson() const {
    return entityToJson
        .set("deliveryNumber", deliveryNumber)
        .set("description", description)
        .set("direction", direction.to!string)
        .set("status", status.to!string)
        .set("shipmentId", shipmentId.value)
        .set("warehouseId", warehouseId)
        .set("partnerId", partnerId)
        .set("partnerName", partnerName)
        .set("deliveryAddress", deliveryAddress)
        .set("items", items.map!(i => i.toJson).array.toJson)
        .set("plannedDate", Json(plannedDate))
        .set("actualDate", Json(actualDate))
        .set("createdAt", Json(createdAt))
        .set("updatedAt", Json(updatedAt));
  }
}
