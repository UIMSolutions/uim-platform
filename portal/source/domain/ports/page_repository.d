module domain.ports.page_repository;

import domain.entities.page;
import domain.types;

/// Port: outgoing — page persistence.
interface PageRepository
{
    Page findById(PageId id);
    Page[] findBySite(SiteId siteId, uint offset = 0, uint limit = 100);
    Page findByAlias(SiteId siteId, string alias_);
    void save(Page page);
    void update(Page page);
    void remove(PageId id);
}
