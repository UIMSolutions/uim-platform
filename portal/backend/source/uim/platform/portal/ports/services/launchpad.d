/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.services.launchpad;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Driving port: the launchpad as one user sees it — the site's CDM document
/// with only the content the user's roles allow, localized to a language.
interface ILaunchpadService {
  /// Throws PortalException (403 no access, 404 unknown site, 409 not published).
  Json launchpad(LaunchpadRequest request);
}
