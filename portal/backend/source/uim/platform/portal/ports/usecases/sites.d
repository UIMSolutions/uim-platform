/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.usecases.sites;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Sites and their publishing lifecycle.
interface IManageSitesUseCase : IManageResource!(PortalSite, SiteId, CreateSiteRequest, UpdateSiteRequest) {
  /// draft | unpublished | published → published (new version). Fails with the blockers.
  UsecaseResult publish(TenantId tenantId, SiteId id, UserId actor);
  /// published → unpublished.
  UsecaseResult unpublish(TenantId tenantId, SiteId id, UserId actor);
  /// any → archived.
  UsecaseResult archive(TenantId tenantId, SiteId id, UserId actor);
  /// archived → draft.
  UsecaseResult restore(TenantId tenantId, SiteId id, UserId actor);
}
