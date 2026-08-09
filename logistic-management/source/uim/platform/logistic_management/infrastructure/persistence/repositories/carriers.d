/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.infrastructure.persistence.repositories.carriers;
import uim.platform.logistic_management;
import std.algorithm : filter, any;
import std.array : array;

mixin(ShowModule!());

@safe:
class CarrierRepository : TenantRepository!(Carrier, CarrierId), ICarrierRepository {
  override Carrier[] findByStatus(TenantId tenantId, CarrierStatus status) {
    return findByTenant(tenantId).filter!(c => c.status == status).array;
  }

  override Carrier[] findByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).filter!(c => c.name == name).array;
  }

  override bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(c => c.name == name);
  }
}
