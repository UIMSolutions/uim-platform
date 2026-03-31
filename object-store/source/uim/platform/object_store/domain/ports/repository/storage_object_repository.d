module uim.platform.object_store.domain.ports.repositories.storage_object_repository;

import domain.entities.storage_object;
import domain.types;

/// Port: outgoing - storage object persistence.
interface StorageObjectRepository
{
    StorageObject findById(ObjectId id);
    StorageObject findByKey(BucketId bucketId, string key);
    StorageObject[] findByBucket(BucketId bucketId);
    StorageObject[] findByPrefix(BucketId bucketId, string prefix);
    void save(StorageObject obj);
    void update(StorageObject obj);
    void remove(ObjectId id);
}
