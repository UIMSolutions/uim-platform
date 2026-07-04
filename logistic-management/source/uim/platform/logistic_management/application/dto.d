/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.application.dto;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
// ─── Carrier DTOs ────────────────────────────────────────────────────────────

struct CreateCarrierRequest {
  string name;
  string description;
  string contactEmail;
  string contactPhone;
  string addressStreet;
  string addressCity;
  string addressCountry;
  string taxId;
  string[] supportedModes;
}

struct UpdateCarrierRequest {
  string description;
  string contactEmail;
  string contactPhone;
  string addressStreet;
  string addressCity;
  string addressCountry;
  string status;
  string[] supportedModes;
}

// ─── FreightOrder DTOs ───────────────────────────────────────────────────────

struct CreateFreightOrderRequest {
  string orderNumber;
  string description;
  string originName;
  string originAddress;
  string destinationName;
  string destinationAddress;
  string carrierId;
  string transportMode;
  double weightKg;
  double volumeM3;
  long plannedDepartureAt;
  long plannedArrivalAt;
}

struct UpdateFreightOrderRequest {
  string description;
  string originName;
  string originAddress;
  string destinationName;
  string destinationAddress;
  string carrierId;
  string transportMode;
  double weightKg;
  double volumeM3;
  long plannedDepartureAt;
  long plannedArrivalAt;
}

struct TransitionFreightOrderRequest {
  string status;
  string statusMessage;
  long actualDepartureAt;
  long actualArrivalAt;
}

// ─── Shipment DTOs ───────────────────────────────────────────────────────────

struct CreateShipmentRequest {
  string shipmentNumber;
  string description;
  string direction;
  string freightOrderId;
  string warehouseId;
  string partnerId;
  string partnerName;
  string trackingNumber;
  long plannedDate;
}

struct UpdateShipmentRequest {
  string description;
  string status;
  string trackingNumber;
  long actualDate;
}

// ─── Delivery DTOs ───────────────────────────────────────────────────────────

struct DeliveryItemRequest {
  string itemNumber;
  string productId;
  string productDescription;
  double quantity;
  string unit;
  double weightKg;
  double volumeM3;
}

struct CreateDeliveryRequest {
  string deliveryNumber;
  string description;
  string direction;
  string shipmentId;
  string warehouseId;
  string partnerId;
  string partnerName;
  string deliveryAddress;
  DeliveryItemRequest[] items;
  long plannedDate;
}

struct UpdateDeliveryRequest {
  string description;
  string status;
  string deliveryAddress;
  long actualDate;
}

// ─── WarehouseOrder DTOs ─────────────────────────────────────────────────────

struct CreateWarehouseOrderRequest {
  string orderNumber;
  string description;
  string deliveryId;
  string warehouseId;
  string assignedTo;
  long dueAt;
}

struct UpdateWarehouseOrderRequest {
  string description;
  string status;
  string assignedTo;
  long dueAt;
}

// ─── WarehouseTask DTOs ──────────────────────────────────────────────────────

struct CreateWarehouseTaskRequest {
  string taskNumber;
  string taskType;
  string warehouseOrderId;
  string warehouseId;
  string sourceStorageBin;
  string destinationStorageBin;
  string productId;
  string productDescription;
  double quantity;
  string unit;
  string assignedTo;
}

struct ConfirmWarehouseTaskRequest {
  string assignedTo;
  long confirmedAt;
}
