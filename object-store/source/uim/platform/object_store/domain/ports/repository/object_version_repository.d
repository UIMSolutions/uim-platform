/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.ports.repositories.object_version;

import uim.platform.object_store.domain.entities.object_version;
import uim.platform.object_store.domain.types;

/// Port: outgoing - object version persistence.
interface ObjectVersionRepository
{
  ObjectVersion findById(ObjectVersionId id);
  ObjectVersion[] findByObject(ObjectId objectId);
  ObjectVersion findLatest(ObjectId objectId);
  void save(ObjectVersion ver);
  void remove(ObjectVersionId id);
  void removeByObject(ObjectId objectId);
}
