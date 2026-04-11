/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.labels;

// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.label;
// import uim.platform.management.domain.ports.repositories.labels;

// // import std.algorithm : filter, canFind;
// // import std.array : array;

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemoryLabelRepository : LabelRepository {
  private Label[LabelId] store;

  bool existsById(LabelId id) {
    return (id in store) ? true : false;
  }

  Label findById(LabelId id) {
    return existsById(id) ? store[id] : Label.init;
  }

  Label[] findByResourceType(LabeledResourceType resourceType) {
    return store.byValue().filter!(e => e.resourceType == resourceType).array;
  }

  Label[] findByResource(LabeledResourceType resourceType, string resourceId) {
    return findByResourceType(resourceType).filter!(e => e.resourceId == resourceId).array;
  }

  Label[] findByKey(LabeledResourceType resourceType, string key) {
    return findByResourceType(resourceType).filter!(e => e.key == key).array;
  }

  Label[] findByKeyValue(LabeledResourceType resourceType, string key, string value) {
    return findByResourceType(resourceType).filter!(e => e.key == key && e.values.canFind(value)).array;
  }

  void save(Label lbl) {
    store[lbl.id] = lbl;
  }

  void update(Label lbl) {
    store[lbl.id] = lbl;
  }

  void remove(LabelId id) {
    store.remove(id);
  }

  void removeByResource(LabeledResourceType resourceType, string resourceId) {
    LabelId[] toRemove;
    foreach (kv; store.byKeyValue()) {
      if (kv.value.resourceType == resourceType && kv.value.resourceId == resourceId)
        toRemove ~= kv.key;
    }
    foreach (id; toRemove)
      store.remove(id);
  }
}
