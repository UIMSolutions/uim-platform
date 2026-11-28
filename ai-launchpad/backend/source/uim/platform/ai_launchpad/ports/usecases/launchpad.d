/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the launchpad: the tile catalog (administration) and
/// the tiles of the current user.
module uim.platform.ai_launchpad.ports.usecases.launchpad;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

interface IManageTiles : IManageResource!(Tile, TileId, TileInput) {
  /// The visible tiles the scopes permit, ordered by group and sort order,
  /// with the current KPI values.
  LaunchpadTile[] launchpad(TenantId t, const string[] scopes, bool enforceScopes);
  /// Create the default tiles if the tenant has none; returns the number created.
  size_t ensureDefaults(TenantId t);
  /// Replace the catalog by the default tiles; returns the number of tiles.
  size_t restoreDefaults(TenantId t, UserId actor);
}
