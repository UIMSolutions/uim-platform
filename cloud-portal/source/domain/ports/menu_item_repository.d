module domain.ports.menu_item_repository;

import domain.entities.menu_item;
import domain.types;

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
