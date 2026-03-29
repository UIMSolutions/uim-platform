module domain.services.content_resolver;

import domain.entities.site;
import domain.entities.page;
import domain.entities.section;
import domain.entities.tile;
import domain.entities.menu_item;
import domain.types;

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
