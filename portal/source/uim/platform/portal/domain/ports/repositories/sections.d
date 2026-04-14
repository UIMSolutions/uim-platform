/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.ports.repositories.sections;

import uim.platform.portal.domain.entities.section;
import uim.platform.portal.domain.types;

/// Port: outgoing — section persistence.
interface SectionRepository {
  bool existsById(SectionId id);
  PortalSection findById(SectionId id);

  PortalSection[] findByPage(PageId pageId);

  void save(PortalSection section);
  void update(PortalSection section);
  void remove(SectionId id);
}
