/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.page;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// A page of a site; contains sections.
struct PortalPage {
  mixin TenantEntity!PageId;

  SiteId siteId;
  string name;
  string description;
  /// URL slug, unique per site.
  string alias_;
  PageLayout layout = PageLayout.freeform;
  int sortOrder;
  bool visible = true;
  PortalRoleId[] allowedRoleIds;
}
