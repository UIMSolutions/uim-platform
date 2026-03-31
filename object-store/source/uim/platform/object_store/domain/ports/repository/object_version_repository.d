module uim.platform.object_store.domain.ports.repositories.object_version;

import domain.entities.object_version;
import domain.types;

/// Port: outgoing - object version persistence.
interface ObjectVersionRepository {
  ObjectVersion findById(ObjectVersionId id);
  ObjectVersion[] findByObject(ObjectId objectId);
  ObjectVersion findLatest(ObjectId objectId);
  void save(ObjectVersion ver);
  void remove(ObjectVersionId id);
  void removeByObject(ObjectId objectId);
}
