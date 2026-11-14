/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.usecases.menu_items;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Navigation menu items of a site.
interface IManageMenuItemsUseCase : IManageResource!(PortalMenuItem, MenuItemId,
    CreateMenuItemRequest, UpdateMenuItemRequest) {
}
