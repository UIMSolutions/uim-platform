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
