/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.services.directory;

import uim.platform.management;

mixin(ShowModule!());

@safe:

class DirectoryApi : IDirectoryApi {
  protected IManageDirectoriesUseCase usecase;

  this(IManageDirectoriesUseCase usecase) {
    this.usecase = usecase;
  }

  Json listDirectories(string tenantId, string globalAccountId, string parentDirectoryId) {
    AccountDirectory[] items;
    if (parentDirectoryId.length > 0)
      items = usecase.listDirectories(tenant(tenantId), DirectoryId(parentDirectoryId));
    else if (globalAccountId.length > 0)
      items = usecase.listDirectories(tenant(tenantId), GlobalAccountId(globalAccountId));
    else
      items = usecase.listDirectories(tenant(tenantId));
    return collectionOf(items);
  }

  Json getDirectory(string tenantId, string _id) {
    auto id = _id;
    return entityOrNotFound(usecase.getDirectory(tenant(tenantId), DirectoryId(id)), "Directory");
  }

  Json createDirectory(string tenantId, CreateDirectoryRequest request) {
    request.tenantId = tenant(tenantId);
    return resultOf(usecase.createDirectory(request));
  }
}
