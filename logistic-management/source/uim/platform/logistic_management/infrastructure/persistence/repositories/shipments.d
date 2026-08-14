/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.infrastructure.persistence.repositories.shipments;
import uim.platform.logistic_management;
import std.algorithm : filter, each;


mixin(ShowModule!());

@safe:
class ShipmentRepository : TenantRepository!(Shipment, ShipmentId), IShipmentRepository {
  size_t countByFreightOrder(TenantId tenantId, FreightOrderId freightOrderId) {
    return findByFreightOrder(tenantId, freightOrderId).length;
  }
  
  Shipment[] filterByFreightOrder(Shipment[] shipments, FreightOrderId freightOrderId) {
    return shipments.filter!(s => s.freightOrderId.value == freightOrderId.value).array;
  }

  Shipment[] findByFreightOrder(TenantId tenantId, FreightOrderId freightOrderId) {
    return filterByFreightOrder(findByTenant(tenantId), freightOrderId);
  }

  void removeByFreightOrder(TenantId tenantId, FreightOrderId freightOrderId) {
    findByFreightOrder(tenantId, freightOrderId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, ShipmentStatus status) {
    return findByStatus(tenantId, status).length;
  }

  Shipment[] filterByStatus(Shipment[] shipments, ShipmentStatus status) {
    return shipments.filter!(s => s.status == status).array;
  }

  Shipment[] findByStatus(TenantId tenantId, ShipmentStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, ShipmentStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

  size_t countByDirection(TenantId tenantId, LogisticsDirection direction) {
    return findByDirection(tenantId, direction).length;
  }

  Shipment[] filterByDirection(Shipment[] shipments, LogisticsDirection direction) {
    return shipments.filter!(s => s.direction == direction).array;
  }

  Shipment[] findByDirection(TenantId tenantId, LogisticsDirection direction) {
    return filterByDirection(findByTenant(tenantId), direction);
  }

  void removeByDirection(TenantId tenantId, LogisticsDirection direction) {
    findByDirection(tenantId, direction).each!(e => remove(e));
  }

  size_t countByPartner(TenantId tenantId, string partnerId) {
    return findByPartner(tenantId, partnerId).length;
  }

  Shipment[] filterByPartner(Shipment[] shipments, string partnerId) {
    return shipments.filter!(s => s.partnerId == partnerId).array;
  }

  Shipment[] findByPartner(TenantId tenantId, string partnerId) {
    return filterByPartner(findByTenant(tenantId), partnerId);
  }

  void removeByPartner(TenantId tenantId, string partnerId) {
    findByPartner(tenantId, partnerId).each!(e => remove(e));
  }
}
