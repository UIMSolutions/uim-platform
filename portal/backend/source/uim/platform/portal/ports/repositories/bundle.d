/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.repositories.bundle;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// All driven persistence ports, handed to the interactors by the container.
struct PortalRepositories {
  ISiteRepository sites;
  IPageRepository pages;
  ISectionRepository sections;
  ITileRepository tiles;
  ICatalogRepository catalogs;
  IContentProviderRepository providers;
  IRoleRepository roles;
  IThemeRepository themes;
  IMenuItemRepository menuItems;
  ITranslationRepository translations;
}
