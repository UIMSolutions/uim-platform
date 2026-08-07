/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.usecases.directories;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage directory hierarchy within global accounts.
interface IManageDirectoriesUseCase { 

  CommandResult createDirectory(CreateDirectoryRequest request);
  CommandResult updateDirectory(UpdateDirectoryRequest request);
  Directory getDirectory(TenantId tenantId, DirectoryId id);
  Directory[] listDirectories(TenantId tenantId, GlobalAccountId gaId);
  Directory[] listDirectories(TenantId tenantId, DirectoryId parentId);
  CommandResult deleteDirectory(TenantId tenantId, DirectoryId id);

}
