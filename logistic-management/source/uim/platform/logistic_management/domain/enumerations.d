/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.enumerations;
import uim.platform.logistic_management;

// mixin(ShowModule!());

@safe:
/// Direction of a shipment or delivery.
enum LogisticsDirection {
  outbound,
  inbound,
}

/// Lifecycle status of a freight order.
enum FreightOrderStatus {
  draft,
  planned,
  inTransit,
  delivered,
  cancelled,
}

/// Lifecycle status of a shipment.
enum ShipmentStatus {
  created,
  inProgress,
  shipped,
  delivered,
  cancelled,
}

/// Lifecycle status of a delivery document.
enum DeliveryStatus {
  created,
  picking,
  packed,
  shipped,
  delivered,
  cancelled,
}

/// Type and status of a warehouse task.
enum WarehouseTaskType {
  picking,
  packing,
  putaway,
  transfer,
  counting,
}

enum WarehouseTaskStatus {
  created,
  queued,
  inProgress,
  confirmed,
  cancelled,
}

/// Status of a warehouse order.
enum WarehouseOrderStatus {
  created,
  released,
  inProgress,
  completed,
  cancelled,
}

/// Carrier / transport service provider status.
enum CarrierStatus {
  active,
  inactive,
  suspended,
}

/// Transportation mode.
enum TransportMode {
  road,
  rail,
  sea,
  air,
  multimodal,
}

/// Handling unit type (packaging level).
enum HandlingUnitType {
  pallet,
  carton,
  crate,
  container,
  drum,
}
