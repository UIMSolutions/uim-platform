/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.enumerations.sites;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Lifecycle of a site.
enum SiteStatus {
  draft,
  published,
  maintenance,
  archived,
}

/// Kind of navigation entry.
enum NavigationItemType {
  link,
  externalLink,
  app,
  workpage,
  group,
  separator,
}

/// Kind of user group.
enum GroupType {
  security,
  distribution,
  dynamic,
}

/// SAP base themes a custom theme can extend.
enum BaseTheme : string {
  sapHorizon = "sap_horizon",
  sapHorizonDark = "sap_horizon_dark",
  sapHorizonHcb = "sap_horizon_hcb",
  sapHorizonHcw = "sap_horizon_hcw",
  sapFiori3 = "sap_fiori_3",
  sapFiori3Dark = "sap_fiori_3_dark",
}

///
unittest {
  assert(enumText(BaseTheme.sapHorizonDark) == "sap_horizon_dark");
  assert(parseEnum!BaseTheme("sap_fiori_3", BaseTheme.sapHorizon) == BaseTheme.sapFiori3);
  assert(parseEnum!NavigationItemType("external-link", NavigationItemType.link) == NavigationItemType.externalLink);
}
