/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.ports.usecases.freight_orders;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
interface IManageFreightOrdersUseCase {

  CommandResult createFreightOrder(TenantId tenantId, CreateFreightOrderRequest req);

  CommandResult updateFreightOrder(TenantId tenantId, FreightOrderId id, UpdateFreightOrderRequest req);

  CommandResult transitionFreightOrder(TenantId tenantId, FreightOrderId id, TransitionFreightOrderRequest req);

  CommandResult deleteFreightOrder(TenantId tenantId, FreightOrderId id);

  FreightOrder getFreightOrder(TenantId tenantId, FreightOrderId id);

  FreightOrder[] listFreightOrders(TenantId tenantId);

  FreightOrder[] listByStatus(TenantId tenantId, FreightOrderStatus status);

  FreightOrder[] listByCarrier(TenantId tenantId, CarrierId carrierId);
  
}
