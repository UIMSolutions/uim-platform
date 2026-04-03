module uim.platform.portal.domain.services.content_resolver;

import uim.platform.portal.domain.entities.site;
import uim.platform.portal.domain.entities.page;
import uim.platform.portal.domain.entities.section;
import uim.platform.portal.domain.entities.tile;
import uim.platform.portal.domain.entities.menu_item;
import uim.platform.portal.domain.types;

/// Resolved site tree — a fully expanded view of a site for rendering.
struct ResolvedSite
{
    Site site;
    ResolvedPage[] pages;
    MenuItem[] menuItems;
}

struct ResolvedPage
{
    Page page;
    ResolvedSection[] sections;
}

struct ResolvedSection
{
    Section section;
    Tile[] tiles;
}
