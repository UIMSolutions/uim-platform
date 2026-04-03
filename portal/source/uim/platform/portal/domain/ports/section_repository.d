module uim.platform.xyz.domain.ports.section_repository;

import domain.entities.section;
import domain.types;

/// Port: outgoing — section persistence.
interface SectionRepository
{
    Section findById(SectionId id);
    Section[] findByPage(PageId pageId);
    void save(Section section);
    void update(Section section);
    void remove(SectionId id);
}
