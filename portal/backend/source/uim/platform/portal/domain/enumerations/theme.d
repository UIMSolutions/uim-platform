/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.enumerations.theme;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Colour mode of a theme.
enum ThemeMode {
  light,
  dark,
  highContrast,
  highContrastDark,
}

/// SAP base themes a custom theme is derived from (UI5 theme ids).
enum BaseTheme : string {
  sapHorizon = "sap_horizon",
  sapHorizonDark = "sap_horizon_dark",
  sapHorizonHcb = "sap_horizon_hcb",
  sapHorizonHcw = "sap_horizon_hcw",
  sapFiori3 = "sap_fiori_3",
  sapFiori3Dark = "sap_fiori_3_dark",
  sapFiori3Hcb = "sap_fiori_3_hcb",
  sapFiori3Hcw = "sap_fiori_3_hcw",
}

///
unittest {
  assert(enumText(BaseTheme.sapFiori3) == "sap_fiori_3");
  assert(parseEnum!BaseTheme("sap_horizon_dark", BaseTheme.sapHorizon) == BaseTheme.sapHorizonDark);
  assert(parseEnum!BaseTheme("sapFiori3", BaseTheme.sapHorizon) == BaseTheme.sapFiori3);
}
