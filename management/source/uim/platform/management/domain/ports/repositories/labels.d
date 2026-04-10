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
interface LabelRepository {
  bool existsById(LabelId id);
  Label findById(LabelId id);

  Label[] findByResource(LabeledResourceType resourceType, string resourceId);
  Label[] findByKey(LabeledResourceType resourceType, string key);
  Label[] findByKeyValue(LabeledResourceType resourceType, string key, string value);
  
  void save(Label lbl);
  void update(Label lbl);
  void remove(LabelId id);
  void removeByResource(LabeledResourceType resourceType, string resourceId);
}
