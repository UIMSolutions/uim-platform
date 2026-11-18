/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.services.catalog;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Reference data for value helps (regions, storage classes).
class ObjectStoreCatalogService : IObjectStoreCatalogService {
  protected IaasProvider[] providers;

  /// `providers`: the hyperscalers this deployment offers (null = all).
  this(IaasProvider[] providers = null) {
    this.providers = providers;
  }

  Region[] regions() {
    Region[] result;
    foreach (r; supportedRegions)
      if (providers.length == 0 || providers.canFind(r.provider))
        result ~= r;
    return result;
  }

  StorageClassInfo[] storageClasses() {
    return storageClassCatalog.dup;
  }
}
