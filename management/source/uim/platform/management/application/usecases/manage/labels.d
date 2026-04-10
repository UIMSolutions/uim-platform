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
class ManageLabelsUseCase : UIMUseCase {
  private LabelRepository repo;

  this(LabelRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateLabelRequest req) {
    if (req.resourceid.isEmpty)
      return CommandResult(false, "", "Resource ID is required");
    if (req.key.length == 0)
      return CommandResult(false, "", "Label key is required");
    if (req.values.length == 0)
      return CommandResult(false, "", "At least one label value is required");

    Label label;
    label.id = randomUUID();
    label.resourceType = parseResourceType(req.resourceType);
    label.resourceId = req.resourceId;
    label.key = req.key;
    label.values = req.values;
    label.createdBy = req.createdBy;
    label.createdAt = clockSeconds();
    label.modifiedAt = label.createdAt;

    repo.save(label);
    return CommandResult(true, label.id.toString, "");
  }

  CommandResult update(LabelId id, UpdateLabelRequest req) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Label not found");

    auto label = repo.findById(id);
    label.values = req.values;
    label.modifiedAt = clockSeconds();
    repo.update(label);
    return CommandResult(true, label.id.toString, "");
  }

  Label getById(LabelId id) {
    return repo.findById(id);
  }

  Label[] listByResource(string resourceType, string resourceId) {
    return repo.findByResource(parseResourceType(resourceType), resourceId);
  }

  Label[] listByKey(string resourceType, string key) {
    return repo.findByKey(parseResourceType(resourceType), key);
  }

  CommandResult remove(LabelId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Label not found");

    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  CommandResult removeByResource(string resourceType, string resourceId) {
    repo.removeByResource(parseResourceType(resourceType), resourceId);
    return CommandResult(true, "", "");
  }

  private LabeledResourceType parseResourceType(string s) {
    switch (s) {
    case "globalAccount":
      return LabeledResourceType.globalAccount;
    case "directory":
      return LabeledResourceType.directory;
    case "subaccount":
      return LabeledResourceType.subaccount;
    case "environmentInstance":
      return LabeledResourceType.environmentInstance;
    case "subscription":
      return LabeledResourceType.subscription;
    default:
      return LabeledResourceType.subaccount;
    }
  }
}
