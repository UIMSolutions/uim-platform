/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.enumerations.site;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Publishing lifecycle of a site:
///   draft → published ⇄ unpublished,  (any but archived) → archived → draft (restore)
enum SiteStatus {
  draft,
  published,
  unpublished,
  archived,
}

/// Layout of a page.
enum PageLayout {
  freeform,
  anchored,
  twoColumn,
  threeColumn,
  dashboard,
}

/// Where a tile or menu item opens its target.
enum NavigationTarget {
  inPlace,
  newWindow,
  embedded,
}

///
unittest {
  assert(parseEnum!SiteStatus("PUBLISHED", SiteStatus.draft) == SiteStatus.published);
  assert(parseEnum!PageLayout("two-column", PageLayout.freeform) == PageLayout.twoColumn);
  assert(enumText(NavigationTarget.newWindow) == "newWindow");
}
