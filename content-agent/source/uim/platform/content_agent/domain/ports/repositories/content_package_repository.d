/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.repositories.content_packages;

import uim.platform.content_agent.domain.entities.content_package;
import uim.platform.content_agent.domain.types;

/// Port: outgoing - content package persistence.
interface ContentPackageRepository {
  ContentPackage findById(ContentPackageId id);
  ContentPackage[] findByTenant(TenantId tenantId);
  ContentPackage[] findByStatus(TenantId tenantId, PackageStatus status);
  ContentPackage findByName(TenantId tenantId, string name);
  void save(ContentPackage pkg);
  void update(ContentPackage pkg);
  void remove(ContentPackageId id);
}
