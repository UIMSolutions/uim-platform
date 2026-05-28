/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.ports.repositories.deliveries;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
interface DeliveryRepository : ITenantRepository!(Delivery, DeliveryId) {
  Delivery[] findByShipment(TenantId tenantId, ShipmentId shipmentId);
  Delivery[] findByStatus(TenantId tenantId, DeliveryStatus status);
  Delivery[] findByDirection(TenantId tenantId, LogisticsDirection direction);
  Delivery[] findByPartner(TenantId tenantId, string partnerId);
  void removeByShipment(TenantId tenantId, ShipmentId shipmentId);
}
