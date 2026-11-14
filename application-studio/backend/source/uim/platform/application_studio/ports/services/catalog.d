/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.ports.services.catalog;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Installs the predefined catalogue (SAP dev space types, extensions and
/// project templates) into a tenant. Idempotent: existing names are kept.
interface IStudioCatalogService {
  CatalogSeedReport seed(TenantId tenantId, UserId actor);
}
