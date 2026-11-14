/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.usecases.catalogs;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Content catalogs.
interface IManageCatalogsUseCase : IManageResource!(PortalCatalog, CatalogId, CreateCatalogRequest, UpdateCatalogRequest) {
  UsecaseResult activate(TenantId tenantId, CatalogId id, UserId actor);
  /// Tiles of an inactive catalog disappear from all launchpads.
  UsecaseResult deactivate(TenantId tenantId, CatalogId id, UserId actor);
}
