/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.entities.shipment;
import uim.platform.logistic_management;

// mixin(ShowModule!());

@safe:
/// A shipment document representing the physical movement of goods (inbound or outbound).
struct Shipment {
  mixin TenantEntity!(ShipmentId);

  string shipmentNumber;
  string description;
  LogisticsDirection direction = LogisticsDirection.outbound;
  ShipmentStatus status = ShipmentStatus.created;
  FreightOrderId freightOrderId;
  string warehouseId;
  string partnerId;
  string partnerName;
  string trackingNumber;
  long plannedDate;
  long actualDate;
  long createdAt;
  long updatedAt;

  Json toJson() const {
    return entityToJson
        .set("shipmentNumber", shipmentNumber)
        .set("description", description)
        .set("direction", direction.to!string)
        .set("status", status.to!string)
        .set("freightOrderId", freightOrderId.value)
        .set("warehouseId", warehouseId)
        .set("partnerId", partnerId)
        .set("partnerName", partnerName)
        .set("trackingNumber", trackingNumber)
        .set("plannedDate", Json(plannedDate))
        .set("actualDate", Json(actualDate))
        .set("createdAt", Json(createdAt))
        .set("updatedAt", Json(updatedAt));
  }
}
