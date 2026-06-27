/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.infrastructure.persistence.memory.freight_orders;
import uim.platform.logistic_management;
import std.algorithm : filter;
import std.array : array;

// mixin(ShowModule!());

@safe:
class MemoryFreightOrderRepository : TentRepository!(FreightOrder, FreightOrderId), FreightOrderRepository {
  override FreightOrder[] findByStatus(TenantId tenantId, FreightOrderStatus status) {
    return findAll(tenantId).filter!(o => o.status == status).array;
  }

  override FreightOrder[] findByCarrier(TenantId tenantId, CarrierId carrierId) {
    return findAll(tenantId).filter!(o => o.carrierId.value == carrierId.value).array;
  }

  override FreightOrder[] findByOrderNumber(TenantId tenantId, string orderNumber) {
    return findAll(tenantId).filter!(o => o.orderNumber == orderNumber).array;
  }
}
