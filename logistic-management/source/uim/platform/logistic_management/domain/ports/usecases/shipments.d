/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.ports.usecases.shipments;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
interface IManageShipmentsUseCase {

  CommandResult createShipment(TenantId tenantId, CreateShipmentRequest req);

  CommandResult updateShipment(TenantId tenantId, ShipmentId id, UpdateShipmentRequest req);

  CommandResult deleteShipment(TenantId tenantId, ShipmentId id);

  Shipment getShipment(TenantId tenantId, ShipmentId id);

  Shipment[] listShipments(TenantId tenantId);

  Shipment[] listByFreightOrder(TenantId tenantId, FreightOrderId foId);

  Shipment[] listByDirection(TenantId tenantId, LogisticsDirection dir);
  
}
