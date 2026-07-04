/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.labels;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.label;
// import uim.platform.management.domain.ports.repositories.labels;

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

    auto label = Label(req.tenantId); // , req.createdBy);
    label.resourceType = req.resourceType.to!LabeledResourceType;
    label.resourceId = req.resourceId;
    label.key = req.key;
    label.values = req.values;

    labels.save(label);
    return CommandResult(true, label.id.value, "");
  }

  CommandResult updateLabel(TenantId tenantId, LabelId id, UpdateLabelRequest req) {
    if (!labels.existsById(tenantId, id))
      return CommandResult(false, "", "Label not found");

    Label label = labels.findById(tenantId, id);
    label.values = req.values;
    label.updatedAt = clockSeconds();
    labels.update(label);
    return CommandResult(true, label.id.value, "");
  }

  Label getLabel(TenantId tenantId, LabelId id) {
    return labels.findById(tenantId, id);
  }

  Label[] listLabels(TenantId tenantId, string resourceType, string resourceId) {
    return labels.findByResource(tenantId, resourceType.to!LabeledResourceType, resourceId);
  }

  Label[] listLabelsByKey(TenantId tenantId, string resourceType, string key) {
    return labels.findByKey(tenantId, resourceType.to!LabeledResourceType, key);
  }

  CommandResult deleteLabel(TenantId tenantId, LabelId id) {
    auto label = labels.findById(tenantId, id);
    if (label.isNull)            
      return CommandResult(false, "", "Label not found");

    labels.remove(label);
    return CommandResult(true, label.id.value, "");
  }

  CommandResult deleteByResource(TenantId tenantId, string resourceType, string resourceId) {
    labels.removeByResource(tenantId, resourceType.to!LabeledResourceType, resourceId);
    return CommandResult(true, "", "");
  }

}
