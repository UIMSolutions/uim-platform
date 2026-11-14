/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.enumerations.access;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// What kind of content a role is meant to grant.
enum RoleScope {
  site,
  catalog,
  group,
  page,
}
