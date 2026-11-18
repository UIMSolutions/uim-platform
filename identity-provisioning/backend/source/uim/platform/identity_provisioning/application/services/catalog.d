/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.services.catalog;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// The connector catalogue as a driving port.
class SystemCatalogService : ISystemCatalogService {
  SystemTypeInfo[] systemTypes() {
    return systemTypeCatalog();
  }
}
