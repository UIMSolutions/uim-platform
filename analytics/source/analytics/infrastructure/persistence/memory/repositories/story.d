module analytics.infrastructure.persistence.memory.story_repo;

import analytics.domain.entities.story;
import analytics.domain.repositories.story_repository;
import analytics.domain.values.common;

class InMemoryStoryRepository : StoryRepository {
    private Story[string] store;

    Story findById(EntityId id) {
        if (auto p = id.value in store) return *p;
        return null;
    }

    Story[] findByOwner(EntityId ownerId) {
        Story[] result;
        foreach (s; store.byValue())
            if (s.ownerId == ownerId) result ~= s;
        return result;
    }

    Story[] findAll() { return store.values; }

    void save(Story story) { store[story.id.value] = story; }

    void remove(EntityId id) { store.remove(id.value); }
}
