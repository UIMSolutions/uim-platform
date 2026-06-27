/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.labels;
// import uim.platform.management.domain.entities.label;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
/// Port: outgoing — label/tag persistence.
interface LabelRepository : ITenantRepository!(Label, LabelId) {

  size_t countByResource(TenantId tenantId, LabeledResourceType resourceType, string resourceId);
  Label[] findByResource(TenantId tenantId, LabeledResourceType resourceType, string resourceId);
  void removeByResource(TenantId tenantId, LabeledResourceType resourceType, string resourceId);

  size_t countByKey(TenantId tenantId, LabeledResourceType resourceType, string key);  
  Label[] findByKey(TenantId tenantId, LabeledResourceType resourceType, string key);
  void removeByKey(TenantId tenantId, LabeledResourceType resourceType, string key);

  size_t countByKeyValue(TenantId tenantId, LabeledResourceType resourceType, string key, string value);
  Label[] findByKeyValue(TenantId tenantId, LabeledResourceType resourceType, string key, string value);
  void removeByKeyValue(TenantId tenantId, LabeledResourceType resourceType, string key, string value);  

}
