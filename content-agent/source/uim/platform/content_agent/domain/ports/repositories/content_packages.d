/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.repositories.content_packages;

// import uim.platform.content_agent.domain.entities.content_package;
// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// Port: outgoing - content package persistence.
interface ContentPackageRepository : ITenantRepository!(ContentPackage, ContentPackageId) {
  bool existsByName(TenantId tenantId, string name);
  ContentPackage findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

  size_t countByStatus(TenantId tenantId, PackageStatus status);
  ContentPackage[] findByStatus(TenantId tenantId, PackageStatus status);
  void removeByStatus(TenantId tenantId, PackageStatus status);
}
