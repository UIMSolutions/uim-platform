/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.ports.repositories.practitioners;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

interface PractitionerRepository : ITenantRepository!(Practitioner, PractitionerId) {
  bool existsById(TenantId tenantId, PractitionerId id);
  Practitioner findById(TenantId tenantId, PractitionerId id);
  void removeById(TenantId tenantId, PractitionerId id);
  size_t countByTenant(TenantId tenantId);
  Practitioner[] findByTenantAll(TenantId tenantId);
}
