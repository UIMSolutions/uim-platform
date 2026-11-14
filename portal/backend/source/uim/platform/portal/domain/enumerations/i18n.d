/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.enumerations.i18n;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Kinds of content whose texts can be translated.
enum TranslatableType {
  site,
  page,
  section,
  tile,
  catalog,
  menuItem,
}
