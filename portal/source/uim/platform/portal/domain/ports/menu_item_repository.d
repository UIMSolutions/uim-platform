module uim.platform.portal.domain.ports.menu_item_repository;

import uim.platform.portal.domain.entities.menu_item;
import uim.platform.portal.domain.types;

/// Port: outgoing — menu item persistence.
interface MenuItemRepository
{
    MenuItem findById(MenuItemId id);
    MenuItem[] findBySite(SiteId siteId);
    MenuItem[] findChildren(MenuItemId parentId);
    void save(MenuItem item);
    void update(MenuItem item);
    void remove(MenuItemId id);
}
