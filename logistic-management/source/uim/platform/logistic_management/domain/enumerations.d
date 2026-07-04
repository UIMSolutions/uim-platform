/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.enumerations;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
/// Direction of a shipment or delivery.
enum LogisticsDirection {
  outbound,
  inbound,
}
LogisticsDirection toLogisticsDirection(string value) {
  mixin(EnumSwitch("LogisticsDirection", "LogisticsDirection.outbound"));
}
LogisticsDirection[] toLogisticsDirection(string[] values) {
  return values.map!(v => v.toLogisticsDirection).array;
}
string toString(LogisticsDirection value) {
  return value.to!string();
}
string[] toString(LogisticsDirection[] values) {
  return values.map!(v => v.toString).array;
}
///
unittest {
  mixin(ShowTest!("LogisticsDirection"));

  assert("outbound".toLogisticsDirection == LogisticsDirection.outbound);
  assert("inbound".toLogisticsDirection == LogisticsDirection.inbound);
  assert("unknown".toLogisticsDirection == LogisticsDirection.outbound);

  assert(LogisticsDirection.outbound.toString == "outbound");
  assert(LogisticsDirection.inbound.toString == "inbound");

  assert(["outbound", "inbound"].toLogisticsDirection == [LogisticsDirection.outbound, LogisticsDirection.inbound]);
  assert([LogisticsDirection.outbound, LogisticsDirection.inbound].toString == ["outbound", "inbound"]);
}

/// Lifecycle status of a freight order.
enum FreightOrderStatus {
  draft,
  planned,
  inTransit,
  delivered,
  cancelled,
}
FreightOrderStatus toFreightOrderStatus(string value) {
  mixin(EnumSwitch("FreightOrderStatus", "FreightOrderStatus.draft"));
}
FreightOrderStatus[] toFreightOrderStatus(string[] values) {
  return values.map!(v => v.toFreightOrderStatus).array;
}
string toString(FreightOrderStatus value) {
  return value.to!string(); 
}
string[] toString(FreightOrderStatus[] values) {
  return values.map!(v => v.toString()).array;
}
/// 
unittest {
  mixin(ShowTest!("FreightOrderStatus"));

  assert("draft".toFreightOrderStatus == FreightOrderStatus.draft);
  assert("planned".toFreightOrderStatus == FreightOrderStatus.planned);
  assert("inTransit".toFreightOrderStatus == FreightOrderStatus.inTransit);
  assert("delivered".toFreightOrderStatus == FreightOrderStatus.delivered);
  assert("cancelled".toFreightOrderStatus == FreightOrderStatus.cancelled);
  assert("unknown".toFreightOrderStatus == FreightOrderStatus.draft);

  assert(FreightOrderStatus.draft.toString == "draft");
  assert(FreightOrderStatus.planned.toString == "planned");
  assert(FreightOrderStatus.inTransit.toString == "inTransit");
  assert(FreightOrderStatus.delivered.toString == "delivered");
  assert(FreightOrderStatus.cancelled.toString == "cancelled");

  assert(["draft", "planned"].toFreightOrderStatus == [FreightOrderStatus.draft, FreightOrderStatus.planned]);
  assert([FreightOrderStatus.draft, FreightOrderStatus.planned].toString == ["draft", "planned"]);
}

/// Lifecycle status of a shipment.
enum ShipmentStatus {
  created,
  inProgress,
  shipped,
  delivered,
  cancelled,
}
ShipmentStatus toShipmentStatus(string value) {
  mixin(EnumSwitch("ShipmentStatus", "ShipmentStatus.created"));
}
ShipmentStatus[] toShipmentStatus(string[] values) {
  return values.map!(v => v.toShipmentStatus).array;
}
string toString(ShipmentStatus value) {
  return value.to!string();
}
string[] toString(ShipmentStatus[] values) {
  return values.map!(v => v.toString()).array;
}
/// 
unittest {
  mixin(ShowTest!("ShipmentStatus"));

  assert("created".toShipmentStatus == ShipmentStatus.created);
  assert("inProgress".toShipmentStatus == ShipmentStatus.inProgress);
  assert("shipped".toShipmentStatus == ShipmentStatus.shipped);
  assert("delivered".toShipmentStatus == ShipmentStatus.delivered);
  assert("cancelled".toShipmentStatus == ShipmentStatus.cancelled);
  assert("unknown".toShipmentStatus == ShipmentStatus.created);

  assert(ShipmentStatus.created.toString == "created");
  assert(ShipmentStatus.inProgress.toString == "inProgress");
  assert(ShipmentStatus.shipped.toString == "shipped");
  assert(ShipmentStatus.delivered.toString == "delivered");
  assert(ShipmentStatus.cancelled.toString == "cancelled");

  assert(["created", "shipped"].toShipmentStatus == [ShipmentStatus.created, ShipmentStatus.shipped]);
  assert([ShipmentStatus.created, ShipmentStatus.shipped].toString == ["created", "shipped"]);
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
DeliveryStatus toDeliveryStatus(string value) {
  mixin(EnumSwitch("DeliveryStatus", "DeliveryStatus.created"));
}
DeliveryStatus[] toDeliveryStatus(string[] values) {
  return values.map!(v => v.toDeliveryStatus).array;
}
string toString(DeliveryStatus value) {
  return value.to!string();
}
string[] toString(DeliveryStatus[] values) {
  return values.map!(v => v.toString()).array;
}
/// 
unittest {
  mixin(ShowTest!("DeliveryStatus"));

  assert("created".toDeliveryStatus == DeliveryStatus.created);
  assert("picking".toDeliveryStatus == DeliveryStatus.picking);
  assert("packed".toDeliveryStatus == DeliveryStatus.packed);
  assert("shipped".toDeliveryStatus == DeliveryStatus.shipped);
  assert("delivered".toDeliveryStatus == DeliveryStatus.delivered);
  assert("cancelled".toDeliveryStatus == DeliveryStatus.cancelled);
  assert("unknown".toDeliveryStatus == DeliveryStatus.created);

  assert(DeliveryStatus.created.toString == "created");
  assert(DeliveryStatus.picking.toString == "picking");
  assert(DeliveryStatus.packed.toString == "packed");
  assert(DeliveryStatus.shipped.toString == "shipped");
  assert(DeliveryStatus.delivered.toString == "delivered");
  assert(DeliveryStatus.cancelled.toString == "cancelled");

  assert(["created", "shipped"].toDeliveryStatus == [DeliveryStatus.created, DeliveryStatus.shipped]);
  assert([DeliveryStatus.created, DeliveryStatus.shipped].toString == ["created", "shipped"]);
}

/// Type and status of a warehouse task.
enum WarehouseTaskType {
  picking,
  packing,
  putaway,
  transfer,
  counting,
}
WarehouseTaskType toWarehouseTaskType(string value) {
  mixin(EnumSwitch("WarehouseTaskType", "WarehouseTaskType.picking"));
}
WarehouseTaskType[] toWarehouseTaskType(string[] values) {
  return values.map!(v => v.toWarehouseTaskType).array;
}
string toString(WarehouseTaskType value) {
  return value.to!string();
}
string[] toString(WarehouseTaskType[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("WarehouseTaskType"));

  assert("picking".toWarehouseTaskType == WarehouseTaskType.picking);
  assert("packing".toWarehouseTaskType == WarehouseTaskType.packing);
  assert("putaway".toWarehouseTaskType == WarehouseTaskType.putaway);
  assert("transfer".toWarehouseTaskType == WarehouseTaskType.transfer);
  assert("counting".toWarehouseTaskType == WarehouseTaskType.counting);
  assert("unknown".toWarehouseTaskType == WarehouseTaskType.picking);

  assert(WarehouseTaskType.picking.toString == "picking");
  assert(WarehouseTaskType.packing.toString == "packing");
  assert(WarehouseTaskType.putaway.toString == "putaway");
  assert(WarehouseTaskType.transfer.toString == "transfer");
  assert(WarehouseTaskType.counting.toString == "counting");

  assert(["picking", "packing"].toWarehouseTaskType == [WarehouseTaskType.picking, WarehouseTaskType.packing]);
  assert([WarehouseTaskType.picking, WarehouseTaskType.packing].toString == ["picking", "packing"]);
}

enum WarehouseTaskStatus {
  created,
  queued,
  inProgress,
  confirmed,
  cancelled,
}
WarehouseTaskStatus toWarehouseTaskStatus(string value) {
  mixin(EnumSwitch("WarehouseTaskStatus", "WarehouseTaskStatus.created"));
}
WarehouseTaskStatus[] toWarehouseTaskStatus(string[] values) {
  return values.map!(v => v.toWarehouseTaskStatus).array;
}
string toString(WarehouseTaskStatus value) {
  return value.to!string();
}
string[] toString(WarehouseTaskStatus[] values) {
  return values.map!(v => v.toString()).array;
}
/// 
unittest {
  mixin(ShowTest!("WarehouseTaskStatus"));

  assert("created".toWarehouseTaskStatus == WarehouseTaskStatus.created);
  assert("queued".toWarehouseTaskStatus == WarehouseTaskStatus.queued);
  assert("inProgress".toWarehouseTaskStatus == WarehouseTaskStatus.inProgress);
  assert("confirmed".toWarehouseTaskStatus == WarehouseTaskStatus.confirmed);
  assert("cancelled".toWarehouseTaskStatus == WarehouseTaskStatus.cancelled);
  assert("unknown".toWarehouseTaskStatus == WarehouseTaskStatus.created);

  assert(WarehouseTaskStatus.created.toString == "created");
  assert(WarehouseTaskStatus.queued.toString == "queued");
  assert(WarehouseTaskStatus.inProgress.toString == "inProgress");
  assert(WarehouseTaskStatus.confirmed.toString == "confirmed");
  assert(WarehouseTaskStatus.cancelled.toString == "cancelled");

  assert(["created", "inProgress"].toWarehouseTaskStatus == [WarehouseTaskStatus.created, WarehouseTaskStatus.inProgress]);
  assert([WarehouseTaskStatus.created, WarehouseTaskStatus.inProgress].toString == ["created", "inProgress"]);
}

/// Status of a warehouse order.
enum WarehouseOrderStatus {
  created,
  released,
  inProgress,
  completed,
  cancelled,
}
WarehouseOrderStatus toWarehouseOrderStatus(string value) {
  mixin(EnumSwitch("WarehouseOrderStatus", "WarehouseOrderStatus.created"));
}
WarehouseOrderStatus[] toWarehouseOrderStatus(string[] values) {
  return values.map!(v => v.toWarehouseOrderStatus).array;
}
string toString(WarehouseOrderStatus value) {
  return value.to!string();
}
string[] toString(WarehouseOrderStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("WarehouseOrderStatus"));

  assert("created".toWarehouseOrderStatus == WarehouseOrderStatus.created);
  assert("released".toWarehouseOrderStatus == WarehouseOrderStatus.released);
  assert("inProgress".toWarehouseOrderStatus == WarehouseOrderStatus.inProgress);
  assert("completed".toWarehouseOrderStatus == WarehouseOrderStatus.completed); 
  assert("cancelled".toWarehouseOrderStatus == WarehouseOrderStatus.cancelled);
  assert("unknown".toWarehouseOrderStatus == WarehouseOrderStatus.created);

  assert(WarehouseOrderStatus.created.toString == "created");
  assert(WarehouseOrderStatus.released.toString == "released");
  assert(WarehouseOrderStatus.inProgress.toString == "inProgress");
  assert(WarehouseOrderStatus.completed.toString == "completed"); 
  assert(WarehouseOrderStatus.cancelled.toString == "cancelled");

  assert(["created", "inProgress"].toWarehouseOrderStatus == [WarehouseOrderStatus.created, WarehouseOrderStatus.inProgress]);
  assert([WarehouseOrderStatus.created, WarehouseOrderStatus.inProgress].toString == ["created", "inProgress"]);
}

/// Carrier / transport service provider status.
enum CarrierStatus {
  active,
  inactive,
  suspended,
}
CarrierStatus toCarrierStatus(string value) {
  mixin(EnumSwitch("CarrierStatus", "CarrierStatus.active"));
} 
CarrierStatus[] toCarrierStatus(string[] values) {
  return values.map!(v => v.toCarrierStatus).array;
}
string toString(CarrierStatus value) {
  return value.to!string();
}
string[] toString(CarrierStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("CarrierStatus"));

  assert("active".toCarrierStatus == CarrierStatus.active);
  assert("inactive".toCarrierStatus == CarrierStatus.inactive);
  assert("suspended".toCarrierStatus == CarrierStatus.suspended);
  assert("unknown".toCarrierStatus == CarrierStatus.active);

  assert(CarrierStatus.active.toString == "active");
  assert(CarrierStatus.inactive.toString == "inactive");
  assert(CarrierStatus.suspended.toString == "suspended");

  assert(["active", "inactive"].toCarrierStatus == [CarrierStatus.active, CarrierStatus.inactive]);
  assert([CarrierStatus.active, CarrierStatus.inactive].toString == ["active", "inactive"]);
}

/// Transportation mode.
enum TransportMode {
  road,
  rail,
  sea,
  air,
  multimodal,
}
TransportMode toTransportMode(string value) {
  mixin(EnumSwitch("TransportMode", "TransportMode.road"));
}
TransportMode[] toTransportMode(string[] values) {
  return values.map!(v => v.toTransportMode).array;
}
string toString(TransportMode value) {
  return value.to!string();
}
string[] toString(TransportMode[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("TransportMode"));

  assert("road".toTransportMode == TransportMode.road);
  assert("rail".toTransportMode == TransportMode.rail);
  assert("sea".toTransportMode == TransportMode.sea);
  assert("air".toTransportMode == TransportMode.air);
  assert("multimodal".toTransportMode == TransportMode.multimodal);
  assert("unknown".toTransportMode == TransportMode.road);

  assert(TransportMode.road.toString == "road");
  assert(TransportMode.rail.toString == "rail");
  assert(TransportMode.sea.toString == "sea");
  assert(TransportMode.air.toString == "air");
  assert(TransportMode.multimodal.toString == "multimodal");

  assert(["road", "sea"].toTransportMode == [TransportMode.road, TransportMode.sea]);
  assert([TransportMode.road, TransportMode.sea].toString == ["road", "sea"]);
}

/// Handling unit type (packaging level).
enum HandlingUnitType {
  pallet,
  carton,
  crate,
  container,
  drum,
}
HandlingUnitType toHandlingUnitType(string value) {
  mixin(EnumSwitch("HandlingUnitType", "HandlingUnitType.pallet"));
}
HandlingUnitType[] toHandlingUnitType(string[] values) {
  return values.map!(v => v.toHandlingUnitType).array;
}
string toString(HandlingUnitType value) {
  return value.to!string();
}
string[] toString(HandlingUnitType[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("HandlingUnitType"));

  assert("pallet".toHandlingUnitType == HandlingUnitType.pallet);
  assert("carton".toHandlingUnitType == HandlingUnitType.carton);
  assert("crate".toHandlingUnitType == HandlingUnitType.crate);
  assert("container".toHandlingUnitType == HandlingUnitType.container);
  assert("drum".toHandlingUnitType == HandlingUnitType.drum);
  assert("unknown".toHandlingUnitType == HandlingUnitType.pallet);

  assert(HandlingUnitType.pallet.toString == "pallet");
  assert(HandlingUnitType.carton.toString == "carton");
  assert(HandlingUnitType.crate.toString == "crate");
  assert(HandlingUnitType.container.toString == "container");
  assert(HandlingUnitType.drum.toString == "drum");

  assert(["pallet", "crate"].toHandlingUnitType == [HandlingUnitType.pallet, HandlingUnitType.crate]);
  assert([HandlingUnitType.pallet, HandlingUnitType.crate].toString == ["pallet", "crate"]);
}
