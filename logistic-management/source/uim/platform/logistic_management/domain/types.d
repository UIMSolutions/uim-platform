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
mixin(IdTemplate);}

struct ShipmentId {
mixin(IdTemplate);}

struct DeliveryId {
mixin(IdTemplate);}

struct WarehouseTaskId {
mixin(IdTemplate);}

struct WarehouseOrderId {
mixin(IdTemplate);}

struct CarrierId {
mixin(IdTemplate);}

struct HandlingUnitId {
mixin(IdTemplate);}
