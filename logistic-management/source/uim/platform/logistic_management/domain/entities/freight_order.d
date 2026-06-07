/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.entities.freight_order;
import uim.platform.logistic_management;

// mixin(ShowModule!());

@safe:
/// A freight/transportation order linking an origin to a destination via a carrier.
struct FreightOrder {
  mixin TenantEntity!(FreightOrderId);

  string orderNumber;
  string description;
  string originName;
  string originAddress;
  string destinationName;
  string destinationAddress;
  CarrierId carrierId;
  TransportMode transportMode = TransportMode.road;
  FreightOrderStatus status = FreightOrderStatus.draft;
  string statusMessage;
  /// Gross weight in kg.
  double weightKg;
  /// Volume in m³.
  double volumeM3;
  long plannedDepartureAt;
  long plannedArrivalAt;
  long actualDepartureAt;
  long actualArrivalAt;
  long createdAt;
  long updatedAt;

  Json toJson() const {
    return entityToJson
        .set("orderNumber", orderNumber)
        .set("description", description)
        .set("originName", originName)
        .set("originAddress", originAddress)
        .set("destinationName", destinationName)
        .set("destinationAddress", destinationAddress)
        .set("carrierId", carrierId.value)
        .set("transportMode", transportMode.to!string)
        .set("status", status.to!string)
        .set("statusMessage", statusMessage)
        .set("weightKg", Json(weightKg))
        .set("volumeM3", Json(volumeM3))
        .set("plannedDepartureAt", Json(plannedDepartureAt))
        .set("plannedArrivalAt", Json(plannedArrivalAt))
        .set("actualDepartureAt", Json(actualDepartureAt))
        .set("actualArrivalAt", Json(actualArrivalAt))
        .set("createdAt", Json(createdAt))
        .set("updatedAt", Json(updatedAt));
  }
}
