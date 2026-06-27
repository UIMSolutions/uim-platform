/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.infrastructure.persistence.memory.deliveries;
import uim.platform.logistic_management;
import std.algorithm : filter, each;
import std.array : array;

// mixin(ShowModule!());

@safe:
class MemoryDeliveryRepository : TentRepository!(Delivery, DeliveryId), DeliveryRepository {
  override Delivery[] findByShipment(TenantId tenantId, ShipmentId shipmentId) {
    return findAll(tenantId).filter!(d => d.shipmentId.value == shipmentId.value).array;
  }

  override Delivery[] findByStatus(TenantId tenantId, DeliveryStatus status) {
    return findAll(tenantId).filter!(d => d.status == status).array;
  }

  override Delivery[] findByDirection(TenantId tenantId, LogisticsDirection direction) {
    return findAll(tenantId).filter!(d => d.direction == direction).array;
  }

  override Delivery[] findByPartner(TenantId tenantId, string partnerId) {
    return findAll(tenantId).filter!(d => d.partnerId == partnerId).array;
  }

  override void removeByShipment(TenantId tenantId, ShipmentId shipmentId) {
    auto toRemove = findByShipment(tenantId, shipmentId);
    toRemove.each!(d => remove(tenantId, d.id));
  }
}
