/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.directories;
// import uim.platform.management.domain.entities.directory;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Port: outgoing — directory persistence.
interface IDirectoryRepository : ITenantRepository!(AccountDirectory, DirectoryId) {

  /// Finds all directories for a given tenant and global account.
  /// @param tenantId The tenant ID.
  /// @param globalAccountId The global account ID.
  /// @return An array of directories associated with the specified tenant and global account.
  AccountDirectory[] findByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId);

  /// Finds all directories for a given tenant and parent directory.
  /// @param tenantId The tenant ID.
  /// @param parentDirectoryId The parent directory ID.
  /// @return An array of directories associated with the specified tenant and parent directory.
  AccountDirectory[] findByParent(TenantId tenantId, DirectoryId parentDirectoryId);  

  /// Finds all directories for a given tenant, global account, and status.
  /// @param tenantId The tenant ID.
  /// @param globalAccountId The global account ID.
  /// @param status The status of the directories to retrieve.
  /// @return An array of directories associated with the specified tenant, global account, and status
  AccountDirectory[] findByStatus(TenantId tenantId, GlobalAccountId globalAccountId, DirectoryStatus status);

}
