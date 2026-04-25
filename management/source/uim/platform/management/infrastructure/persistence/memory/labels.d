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

class MemoryLabelRepository : IdRepository!(Label, LabelId), LabelRepository {
  // TODO: mixin IdRepositoryTemplate!(MemoryLabelRepository, Label, LabelId);

  // #region ByResourceType
  size_t countByResourceType(LabeledResourceType resourceType) {
    return findByResourceType(resourceType).length;
  }

  Label[] filterByResourceType(Label[] items, LabeledResourceType resourceType) {
    return items.filter!(e => e.resourceType == resourceType).array;
  }

  Label[] findByResourceType(LabeledResourceType resourceType) {
    return findAll().filterByResourceType(resourceType);
  }

  void removeByResourceType(LabeledResourceType resourceType, bool deleteTenantIfEmpty = false) {
    findByResourceType(resourceType).removeAll(deleteTenantIfEmpty);
  }
  // #endregion ByResourceType

  // #region ByResource
  size_t countByResource(LabeledResourceType resourceType, string resourceId) {
    return findByResource(resourceType, resourceId).length;
  }

  Label[] filterByResource(Label[] items, LabeledResourceType resourceType, string resourceId) {
    return items.filterByResourceType(resourceType).filter!(e => e.resourceId == resourceId).array;
  }

  Label[] findByResource(LabeledResourceType resourceType, string resourceId) {
    return findAll().filterByResource(items, resourceType, resourceId);
  }

  void removeByResource(LabeledResourceType resourceType, string resourceId, bool deleteTenantIfEmpty = false) {
    findByResource(resourceType, resourceId).removeAll(deleteTenantIfEmpty);
  }
  // #endregion ByResource

  // #region ByKey
  size_t countByKey(LabeledResourceType resourceType, string key) {
    return findByKey(resourceType, key).length;
  }

  Label[] filterByKey(Label[] items, LabeledResourceType resourceType, string key) {
    return items.filterByResourceType(resourceType).filter!(e => e.key == key).array;
  }

  Label[] findByKey(LabeledResourceType resourceType, string key) {
    return findByResourceType(resourceType).filter!(e => e.key == key).array;
  }

  void removeByKey(LabeledResourceType resourceType, string key, bool deleteTenantIfEmpty = false) {
    findByKey(resourceType, key).removeAll(deleteTenantIfEmpty);
  } 
  // #endregion ByKey

  // #region ByKeyValue
  size_t countByKeyValue(LabeledResourceType resourceType, string key, string value) {
    return findByKeyValue(resourceType, key, value).length;
  }

  Label[] filterByKeyValue(Label[] items, LabeledResourceType resourceType, string key, string value) {
    return items.filterByResourceType(resourceType).filter!(e => e.key == key && e.values.canFind(value)).array;
  }
  
  Label[] findByKeyValue(LabeledResourceType resourceType, string key, string value) {
    return findByResourceType(resourceType).filterByKeyValue(key, value);
  }

  void removeByKeyValue(LabeledResourceType resourceType, string key, string value, bool deleteTenantIfEmpty = false) {
    findByKeyValue(resourceType, key, value).removeAll(deleteTenantIfEmpty);
  }
  // #endregion ByKeyValue

}
