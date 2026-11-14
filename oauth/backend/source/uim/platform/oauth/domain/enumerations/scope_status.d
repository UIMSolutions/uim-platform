/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.enumerations.scope_status;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// An inactive scope can no longer be granted (existing tokens keep it until they expire).
enum ScopeStatus : string {
  active = "active",
  inactive = "inactive"
}
