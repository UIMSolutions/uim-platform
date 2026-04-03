module uim.platform.xyz.domain.ports.page_repository;

import uim.platform.xyz.domain.entities.page;
import uim.platform.xyz.domain.types;

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
