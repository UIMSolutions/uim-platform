/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.infrastructure.persistence.memory.shipments;
import uim.platform.logistic_management;
import std.algorithm : filter, each;
import std.array : array;

// mixin(ShowModule!());

@safe:
class MemoryShipmentRepository : TentRepository!(Shipment, ShipmentId), ShipmentRepository {
  override Shipment[] findByFreightOrder(TenantId tenantId, FreightOrderId freightOrderId) {
    return findAll(tenantId).filter!(s => s.freightOrderId.value == freightOrderId.value).array;
  }

  override Shipment[] findByStatus(TenantId tenantId, ShipmentStatus status) {
    return findAll(tenantId).filter!(s => s.status == status).array;
  }

  override Shipment[] findByDirection(TenantId tenantId, LogisticsDirection direction) {
    return findAll(tenantId).filter!(s => s.direction == direction).array;
  }

  override Shipment[] findByPartner(TenantId tenantId, string partnerId) {
    return findAll(tenantId).filter!(s => s.partnerId == partnerId).array;
  }

  override void removeByFreightOrder(TenantId tenantId, FreightOrderId freightOrderId) {
    auto toRemove = findByFreightOrder(tenantId, freightOrderId);
    toRemove.each!(s => remove(tenantId, s.id));
  }
}
