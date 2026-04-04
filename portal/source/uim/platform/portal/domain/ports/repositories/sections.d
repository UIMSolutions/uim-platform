/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.ports.section_repository;

import uim.platform.portal.domain.entities.section;
import uim.platform.portal.domain.types;

/// Port: outgoing — section persistence.
interface SectionRepository
{
  Section findById(SectionId id);
  Section[] findByPage(PageId pageId);
  void save(Section section);
  void update(Section section);
  void remove(SectionId id);
}
