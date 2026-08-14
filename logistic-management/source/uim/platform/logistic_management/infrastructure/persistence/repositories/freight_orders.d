/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.infrastructure.persistence.repositories.freight_orders;
import uim.platform.logistic_management;
import std.algorithm : filter;


mixin(ShowModule!());

@safe:
class FreightOrderRepository : TenantRepository!(FreightOrder, FreightOrderId), IFreightOrderRepository {
  
  size_t countByStatus(TenantId tenantId, FreightOrderStatus status) {
    return findByTenant(tenantId).filter!(o => o.status == status).length;
  }

  FreightOrder[] filterByStatus(FreightOrder[] orders, FreightOrderStatus status) {
    return orders.filter!(o => o.status == status).array;
  }

  FreightOrder[] findByStatus(TenantId tenantId, FreightOrderStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByCarrier(TenantId tenantId, CarrierId carrierId) {
    findByCarrier(tenantId, carrierId).each!(e => remove(e));
  }

  size_t countByCarrier(TenantId tenantId, CarrierId carrierId) {
    return findByCarrier(tenantId, carrierId).length;
  }

  FreightOrder[] filterByCarrier(FreightOrder[] orders, CarrierId carrierId) {
    return orders.filter!(o => o.carrierId.value == carrierId.value).array;
  }

  FreightOrder[] findByCarrier(TenantId tenantId, CarrierId carrierId) {
    return filterByCarrier(findByTenant(tenantId), carrierId);
  }

  void removeByOrderNumber(TenantId tenantId, string orderNumber) {
    findByOrderNumber(tenantId, orderNumber).each!(e => remove(e));
  }

  size_t countByOrderNumber(TenantId tenantId, string orderNumber) {
    return findByOrderNumber(tenantId, orderNumber).length;
  }

  FreightOrder[] filterByOrderNumber(FreightOrder[] orders, string orderNumber) {
    return orders.filter!(o => o.orderNumber == orderNumber).array;
  }

  FreightOrder[] findByOrderNumber(TenantId tenantId, string orderNumber) {
    return filterByOrderNumber(findByTenant(tenantId), orderNumber);
  }

}
