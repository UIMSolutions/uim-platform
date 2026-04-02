module domain.ports.directory_repository;

import uim.platform.management.domain.entities.directory;
import uim.platform.management.domain.types;

/// Port: outgoing — directory persistence.
interface DirectoryRepository
{
    Directory findById(DirectoryId id);
    Directory[] findByGlobalAccount(GlobalAccountId globalAccountId);
    Directory[] findByParent(DirectoryId parentDirectoryId);
    Directory[] findByStatus(GlobalAccountId globalAccountId, DirectoryStatus status);
    void save(Directory dir);
    void update(Directory dir);
    void remove(DirectoryId id);
}
