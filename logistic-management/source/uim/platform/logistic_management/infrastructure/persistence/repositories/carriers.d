/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.infrastructure.persistence.repositories.carriers;
import uim.platform.logistic_management;


mixin(ShowModule!());

@safe:
class CarrierRepository : TenantRepository!(Carrier, CarrierId), ICarrierRepository {

  size_t countByStatus(TenantId tenantId, CarrierStatus status)
    => findByStatus(tenantId, status).length;

  Carrier[] filterByStatus(Carrier[] carriers, CarrierStatus status) {
    return carriers.filter!(c => c.status == status).array;
  }

  Carrier[] findByStatus(TenantId tenantId, CarrierStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, CarrierStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

  size_t countByName(TenantId tenantId, string name) {
    return findByName(tenantId, name).length;
  }
  
  Carrier[] filterByName(Carrier[] carriers, string name) {
    return carriers.filter!(c => c.name == name).array;
  }
  
  Carrier[] findByName(TenantId tenantId, string name) {
    return filterByName(findByTenant(tenantId), name);
  }

  void removeByName(TenantId tenantId, string name) {
    findByName(tenantId, name).each!(e => remove(e));
  }

  size_t countByCode(TenantId tenantId, string code) {
    return findByCode(tenantId, code).length;
  }

  Carrier[] filterByCode(Carrier[] carriers, string code) {
    return carriers.filter!(c => c.code == code).array;
  }

  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(c => c.name == name);
  }

  void removeByCode(TenantId tenantId, string code) {
    findByCode(tenantId, code).each!(e => remove(e));
  }

}
