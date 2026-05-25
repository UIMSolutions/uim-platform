/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.ports.repositories.freight_orders;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
interface FreightOrderRepository : ITenantRepository!(FreightOrder, FreightOrderId) {
  FreightOrder[] findByStatus(string tenantId, FreightOrderStatus status);
  FreightOrder[] findByCarrier(string tenantId, CarrierId carrierId);
  FreightOrder[] findByOrderNumber(string tenantId, string orderNumber);
}
