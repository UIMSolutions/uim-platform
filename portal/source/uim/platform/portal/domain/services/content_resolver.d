module uim.platform.xyz.domain.services.content_resolver;

import uim.platform.xyz.domain.entities.site;
import uim.platform.xyz.domain.entities.page;
import uim.platform.xyz.domain.entities.section;
import uim.platform.xyz.domain.entities.tile;
import uim.platform.xyz.domain.entities.menu_item;
import uim.platform.xyz.domain.types;

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
