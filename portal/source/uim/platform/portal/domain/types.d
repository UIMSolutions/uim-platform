/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.types;

import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct SiteId {
  mixin(IdTemplate);
}

struct PageId {
  mixin(IdTemplate);
}

struct SectionId {
  mixin(IdTemplate);
}

struct TileId {
  mixin(IdTemplate);
}

struct CatalogId {
  mixin(IdTemplate);
}

struct GroupId {
  mixin(IdTemplate);
}

struct RoleId {
  mixin(IdTemplate);
}

struct ProviderId {
  mixin(IdTemplate);
}

struct ThemeId {
  mixin(IdTemplate);
}

struct MenuItemId {
  mixin(IdTemplate);
}

struct TranslationId {
  mixin(IdTemplate);
}