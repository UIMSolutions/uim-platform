/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.label_repo;

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

  Label findById(LabelId id) {
    if (auto p = id in store)
      return *p;
    return Label.init;
  }

  Label[] findByResource(LabeledResourceType resourceType, string resourceId) {
    return store.byValue().filter!(e => e.resourceType == resourceType
        && e.resourceId == resourceId).array;
  }

  Label[] findByKey(LabeledResourceType resourceType, string key) {
    return store.byValue().filter!(e => e.resourceType == resourceType && e.key == key).array;
  }

  Label[] findByKeyValue(LabeledResourceType resourceType, string key, string value) {
    return store.byValue().filter!(e => e.resourceType == resourceType
        && e.key == key && e.values.canFind(value)).array;
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
    foreach (ref kv; store.byKeyValue()) {
      if (kv.value.resourceType == resourceType && kv.value.resourceId == resourceId)
        toRemove ~= kv.key;
    }
    foreach (id; toRemove)
      store.remove(id);
  }
}
