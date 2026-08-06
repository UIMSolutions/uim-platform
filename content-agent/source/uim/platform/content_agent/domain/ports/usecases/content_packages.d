/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.usecases.content_packages;

import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// Application service for content package CRUD and assembly.
interface IManageContentPackagesUseCase { 

  CommandResult createPackage(CreatePackageRequest req);
  CommandResult updatePackage(UpdatePackageRequest req);
  CommandResult assemblePackage(AssemblePackageRequest req);
  ContentPackage getPackage(TenantId tenantId, ContentPackageId id);
  ContentPackage[] listPackages(TenantId tenantId);
  ContentPackage[] listByStatus(TenantId tenantId, string statusStr);
  CommandResult deletePackage(TenantId tenantId, ContentPackageId id);

}
