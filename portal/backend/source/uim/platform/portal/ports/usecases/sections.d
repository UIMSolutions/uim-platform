/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.usecases.sections;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Sections of a page and the tiles placed on them.
interface IManageSectionsUseCase : IManageResource!(PortalSection, SectionId, CreateSectionRequest, UpdateSectionRequest) {
  /// Append a tile (id or name) to the section.
  UsecaseResult addTile(TenantId tenantId, SectionId id, string tile, UserId actor);
  /// Remove a tile (id or name) from the section.
  UsecaseResult removeTile(TenantId tenantId, SectionId id, string tile, UserId actor);
}
