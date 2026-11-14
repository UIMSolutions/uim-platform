/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.usecases.themes;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Themes.
interface IManageThemesUseCase : IManageResource!(PortalTheme, ThemeId, CreateThemeRequest, UpdateThemeRequest) {
  /// Make the theme the tenant default (the previous default is reset).
  UsecaseResult makeDefault(TenantId tenantId, ThemeId id, UserId actor);
}
