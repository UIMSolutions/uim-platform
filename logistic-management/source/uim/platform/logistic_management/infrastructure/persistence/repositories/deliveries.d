/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.infrastructure.persistence.repositories.deliveries;
import uim.platform.logistic_management;
import std.algorithm : filter, each;


mixin(ShowModule!());

@safe:
class DeliveryRepository : TenantRepository!(Delivery, DeliveryId), IDeliveryRepository {

  size_t countByShipment(TenantId tenantId, ShipmentId shipmentId) {
    return findByShipment(tenantId, shipmentId).length;
  }

  Delivery[] filterByShipment(Delivery[] deliveries, ShipmentId shipmentId) {
    return deliveries.filter!(d => d.shipmentId.value == shipmentId.value).array;
  }

  Delivery[] findByShipment(TenantId tenantId, ShipmentId shipmentId) {
    return filterByShipment(findByTenant(tenantId), shipmentId);
  }

  void removeByShipment(TenantId tenantId, ShipmentId shipmentId) {
    findByShipment(tenantId, shipmentId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, DeliveryStatus status) {
    return findByStatus(tenantId, status).length;
  }

  Delivery[] filterByStatus(Delivery[] deliveries, DeliveryStatus status) {
    return deliveries.filter!(d => d.status == status).array;
  }

  Delivery[] findByStatus(TenantId tenantId, DeliveryStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, DeliveryStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

  size_t countByDirection(TenantId tenantId, LogisticsDirection direction) {
    return findByDirection(tenantId, direction).length;
  }

  Delivery[] filterByDirection(Delivery[] deliveries, LogisticsDirection direction) {
    return deliveries.filter!(d => d.direction == direction).array;
  }

  Delivery[] findByDirection(TenantId tenantId, LogisticsDirection direction) {
    return filterByDirection(findByTenant(tenantId), direction);
  }

  void removeByDirection(TenantId tenantId, LogisticsDirection direction) {
    findByDirection(tenantId, direction).each!(e => remove(e));
  }

  size_t countByPartner(TenantId tenantId, string partnerId) {
    return findByPartner(tenantId, partnerId).length;
  }

  Delivery[] filterByPartner(Delivery[] deliveries, string partnerId) {
    return deliveries.filter!(d => d.partnerId == partnerId).array;
  }

  Delivery[] findByPartner(TenantId tenantId, string partnerId) {
    return filterByPartner(findByTenant(tenantId), partnerId);
  }

  void removeByPartner(TenantId tenantId, string partnerId) {
    findByPartner(tenantId, partnerId).each!(e => remove(e));
  }
}
