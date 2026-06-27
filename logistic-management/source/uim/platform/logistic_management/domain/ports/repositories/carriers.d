module uim.platform.logistic_management.domain.ports.repositories.carriers;

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.ports.repositories.carriers;
import uim.platform.logistic_management;

// mixin(ShowModule!());

@safe:
interface CarrierRepository : ITenantRepository!(Carrier, CarrierId) {
  Carrier[] findByStatus(TenantId tenantId, CarrierStatus status);
  Carrier[] findByName(TenantId tenantId, string name);
  bool existsByName(TenantId tenantId, string name);
}
