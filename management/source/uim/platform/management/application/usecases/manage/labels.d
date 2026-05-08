/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.labels;

// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.label;
// import uim.platform.management.domain.ports.repositories.labels;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage labels (tags) on BTP resources.
class ManageLabelsUseCase { // TODO: UIMUseCase {
  private LabelRepository labels;

  this(LabelRepository labels) {
    this.labels = labels;
  }

  CommandResult createLabel(CreateLabelRequest req) {
    if (req.resourceId.isEmpty)
      return CommandResult(false, "", "Resource ID is required");
    if (req.key.length == 0)
      return CommandResult(false, "", "Label key is required");
    if (req.values.length == 0)
      return CommandResult(false, "", "At least one label value is required");

    Label label;
    label.id = randomUUID();
    label.resourceType = req.resourceType.to!LabeledResourceType;
    label.resourceId = req.resourceId;
    label.key = req.key;
    label.values = req.values;
    label.createdBy = req.createdBy;
    label.createdAt = clockSeconds();
    label.updatedAt = label.createdAt;

    labels.save(label);
    return CommandResult(true, label.id.value, "");
  }

  CommandResult updateLabel(LabelId id, UpdateLabelRequest req) {
    if (!labels.existsById(id))
      return CommandResult(false, "", "Label not found");

    Label label = labels.findById(tenantId, id);
    label.values = req.values;
    label.updatedAt = clockSeconds();
    labels.update(label);
    return CommandResult(true, label.id.value, "");
  }

  Label getLabel(LabelId id) {
    return labels.findById(tenantId, id);
  }

  Label[] listLabels(string resourceType, string resourceId) {
    return labels.findByResource(resourceType.to!LabeledResourceType, resourceId);
  }

  Label[] listLabels(string resourceType, string key) {
    return labels.findByKey(resourceType.to!LabeledResourceType, key);
  }

  CommandResult deleteLabel(LabelId id) {
    auto label = labels.findById(tenantId, id);
    if (label.isNull)            
      return CommandResult(false, "", "Label not found");

    labels.remove(label);
    return CommandResult(true, label.id.value, "");
  }

  CommandResult deleteByResource(string resourceType, string resourceId) {
    labels.removeByResource(resourceType.to!LabeledResourceType, resourceId);
    return CommandResult(true, "", "");
  }

}
