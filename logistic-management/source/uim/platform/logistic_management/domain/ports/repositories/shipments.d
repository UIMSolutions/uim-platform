/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.ports.repositories.shipments;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
interface ShipmentRepository : ITenantRepository!(Shipment, ShipmentId) {
  Shipment[] findByFreightOrder(string tenantId, FreightOrderId freightOrderId);
  Shipment[] findByStatus(string tenantId, ShipmentStatus status);
  Shipment[] findByDirection(string tenantId, LogisticsDirection direction);
  Shipment[] findByPartner(string tenantId, string partnerId);
  void removeByFreightOrder(string tenantId, FreightOrderId freightOrderId);
}
