/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.ports.repositories.pages;

import uim.platform.portal.domain.entities.page;
import uim.platform.portal.domain.types;

/// Port: outgoing — page persistence.
interface PageRepository {
  bool existsById(PageId id);
  Page findById(PageId id);

  bool existsByAlias(SiteId siteId, string alias_);
  Page findByAlias(SiteId siteId, string alias_);

  Page[] findBySite(SiteId siteId, uint offset = 0, uint limit = 100);
  
  void save(Page page);
  void update(Page page);
  void remove(PageId id);
}
