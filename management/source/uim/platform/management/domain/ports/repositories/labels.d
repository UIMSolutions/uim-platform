/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.labels;

// import uim.platform.management.domain.entities.label;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Port: outgoing — label/tag persistence.
interface LabelRepository : IIdRepository!(Label, LabelId) {

  size_t countByResource(LabeledResourceType resourceType, string resourceId);
  Label[] filterByResource(Label[] items, LabeledResourceType resourceType, string resourceId);
  Label[] findByResource(LabeledResourceType resourceType, string resourceId);
  void removeByResource(LabeledResourceType resourceType, string resourceId);

  size_t countByKey(LabeledResourceType resourceType, string key);  
  Label[] filterByKey(Label[] items, LabeledResourceType resourceType, string key);
  Label[] findByKey(LabeledResourceType resourceType, string key);
  void removeByKey(LabeledResourceType resourceType, string key);

  size_t countByKeyValue(LabeledResourceType resourceType, string key, string value);
  Label[] filterByKeyValue(Label[] items, LabeledResourceType resourceType, string key, string value);
  Label[] findByKeyValue(LabeledResourceType resourceType, string key, string value);
  void removeByKeyValue(LabeledResourceType resourceType, string key, string value);  

}
