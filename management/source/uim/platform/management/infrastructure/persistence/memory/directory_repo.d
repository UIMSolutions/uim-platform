module uim.platform.management.infrastructure.persistence.memory.directory_repo;

import uim.platform.management.domain.types;
import uim.platform.management.domain.entities.directory;
import uim.platform.management.domain.ports.directory_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryDirectoryRepository : DirectoryRepository
{
    private Directory[DirectoryId] store;

    Directory findById(DirectoryId id)
    {
        if (auto p = id in store)
            return *p;
        return Directory.init;
    }

    Directory[] findByGlobalAccount(GlobalAccountId globalAccountId)
    {
        return store.byValue().filter!(e => e.globalAccountId == globalAccountId).array;
    }

    Directory[] findByParent(DirectoryId parentDirectoryId)
    {
        return store.byValue().filter!(e => e.parentDirectoryId == parentDirectoryId).array;
    }

    Directory[] findByStatus(GlobalAccountId globalAccountId, DirectoryStatus status)
    {
        return store.byValue()
            .filter!(e => e.globalAccountId == globalAccountId && e.status == status)
            .array;
    }

    void save(Directory dir) { store[dir.id] = dir; }
    void update(Directory dir) { store[dir.id] = dir; }
    void remove(DirectoryId id) { store.remove(id); }
}
