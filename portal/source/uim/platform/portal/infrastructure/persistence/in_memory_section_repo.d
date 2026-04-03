module uim.platform.portal.infrastructure.persistence.memory.section_repo;

import uim.platform.portal.domain.entities.section;
import uim.platform.portal.domain.types;
import uim.platform.portal.domain.ports.section_repository;

class MemorySectionRepository : SectionRepository
{
    private Section[SectionId] store;

    Section findById(SectionId id)
    {
        if (auto p = id in store)
            return *p;
        return Section.init;
    }

    Section[] findByPage(PageId pageId)
    {
        Section[] result;
        foreach (s; store.byValue())
        {
            if (s.pageId == pageId)
                result ~= s;
        }
        return result;
    }

    void save(Section section)
    {
        store[section.id] = section;
    }

    void update(Section section)
    {
        store[section.id] = section;
    }

    void remove(SectionId id)
    {
        store.remove(id);
    }
}
