/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.ports.usecases.deliveries;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
interface IManageDeliveriesUseCase {

  CommandResult createDelivery(TenantId tenantId, CreateDeliveryRequest req);

  CommandResult updateDeliveryStatus(TenantId tenantId, DeliveryId id, UpdateDeliveryRequest req);

  CommandResult deleteDelivery(TenantId tenantId, DeliveryId id);

  Delivery getDelivery(TenantId tenantId, DeliveryId id);

  Delivery[] listDeliveries(TenantId tenantId);

  Delivery[] listByShipment(TenantId tenantId, ShipmentId shipmentId);

  Delivery[] listByDirection(TenantId tenantId, LogisticsDirection dir);
  
}
