/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.types;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
struct FreightOrderId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct ShipmentId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct DeliveryId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct WarehouseTaskId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct WarehouseOrderId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct CarrierId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct HandlingUnitId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}
