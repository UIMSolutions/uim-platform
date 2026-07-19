/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.ports.repositories.organizations;
import uim.platform.health_fhir;
mixin(ShowModule!());

@safe:

interface OrganizationRepository : ITenantRepository!(Organization, OrganizationId) {
  bool existsById(TenantId tenantId, OrganizationId id);
  Organization findById(TenantId tenantId, OrganizationId id);
  void removeById(TenantId tenantId, OrganizationId id);
  size_t countByTenant(TenantId tenantId);
  Organization[] findByTenantAll(TenantId tenantId);
}
