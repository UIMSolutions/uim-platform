/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.labels;

// import uim.platform.management.domain.entities.label;
// import uim.platform.management.domain.ports.repositories.labels;

//  

import uim.platform.management;

// mixin(ShowModule!());
@safe:

class MemoryLabelRepository : TenantRepository!(Label, LabelId), LabelRepository {
  // TODO: mixin IdRepositoryTemplate!(MemoryLabelRepository, Label, LabelId);

  // #region ByResourceType
  size_t countByResourceType(TenantId tenantId, LabeledResourceType resourceType) {
    return findByResourceType(tenantId, resourceType).length;
  }

  Label[] filterByResourceType(Label[] items, LabeledResourceType resourceType) {
    return items.filter!(e => e.resourceType == resourceType).array;
  }

  Label[] findByResourceType(TenantId tenantId, LabeledResourceType resourceType) {
    return filterByResourceType(findByTenant(tenantId), resourceType);
  }

  void removeByResourceType(TenantId tenantId, LabeledResourceType resourceType) {
    findByResourceType(tenantId, resourceType).each!(e => remove(e));
  }
  // #endregion ByResourceType

  // #region ByResource
  size_t countByResource(TenantId tenantId, LabeledResourceType resourceType, string resourceId) {
    return findByResource(tenantId, resourceType, resourceId).length;
  }

  Label[] filterByResource(Label[] items, LabeledResourceType resourceType, string resourceId) {
    return filterByResourceType(items, resourceType).filter!(e => e.resourceId == resourceId).array;
  }

  Label[] findByResource(TenantId tenantId, LabeledResourceType resourceType, string resourceId) {
    return filterByResource(findByTenant(tenantId), resourceType, resourceId);
  }

  void removeByResource(TenantId tenantId, LabeledResourceType resourceType, string resourceId) {
    findByResource(tenantId, resourceType, resourceId).each!(e => remove(e));
  }
  // #endregion ByResource

  // #region ByKey
  size_t countByKey(TenantId tenantId, LabeledResourceType resourceType, string key) {
    return findByKey(tenantId, resourceType, key).length;
  }

  Label[] filterByKey(Label[] items, LabeledResourceType resourceType, string key) {
    return filterByResourceType(items, resourceType).filter!(e => e.key == key).array;
  }

  Label[] findByKey(TenantId tenantId, LabeledResourceType resourceType, string key) {
    return filterByResourceType(findByTenant(tenantId), resourceType).filter!(e => e.key == key).array;
  }

  void removeByKey(TenantId tenantId, LabeledResourceType resourceType, string key) {
    findByKey(tenantId, resourceType, key).each!(e => remove(e));
  } 
  // #endregion ByKey

  // #region ByKeyValue
  size_t countByKeyValue(TenantId tenantId, LabeledResourceType resourceType, string key, string value) {
    return findByKeyValue(tenantId, resourceType, key, value).length;
  }

  Label[] filterByKeyValue(Label[] items, LabeledResourceType resourceType, string key, string value) {
    return filterByResourceType(items, resourceType).filter!(e => e.key == key && e.values.canFind(value)).array;
  }
  
  Label[] findByKeyValue(TenantId tenantId, LabeledResourceType resourceType, string key, string value) {
    return filterByKeyValue(findByTenant(tenantId), resourceType, key, value);
  }

  void removeByKeyValue(TenantId tenantId, LabeledResourceType resourceType, string key, string value) {
    findByKeyValue(tenantId, resourceType, key, value).each!(e => remove(e));
  }
  // #endregion ByKeyValue

}
///
unittest {
  auto repo = new MemoryLabelRepository();
  auto tenantId = TenantId("tenant1");
  auto labelId = LabelId("label1");
  auto label = Label(tenantId);
  label.id = labelId;
  label.resourceType = LabeledResourceType.globalAccount;
  label.resourceId = "ga1";
  label.key = "env";
  label.values = ["prod", "staging"];

  repo.save(label);

  assert(repo.countByResourceType(tenantId, LabeledResourceType.globalAccount) == 1);
  assert(repo.findByResourceType(tenantId, LabeledResourceType.globalAccount).length == 1);
  assert(repo.findByResourceType(tenantId, LabeledResourceType.globalAccount)[0].id == labelId);

  repo.removeByResourceType(tenantId, LabeledResourceType.globalAccount);
  assert(repo.countByResourceType(tenantId, LabeledResourceType.globalAccount) == 0);
}