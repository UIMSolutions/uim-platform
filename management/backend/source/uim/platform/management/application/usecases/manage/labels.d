/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.labels;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Use case: manage labels (tags) on BTP resources.
class ManageLabelsUseCase : IManageLabelsUseCase {
  protected ILabelRepository labels;

  this(ILabelRepository labels) {
    this.labels = labels;
  }

  UsecaseResult createLabel(CreateLabelRequest req) {
    LabeledResourceType type;
    if (!tryParseEnum!LabeledResourceType(req.resourceType, type))
      return invalid("Unknown resource type '" ~ req.resourceType ~ "' (expected "
          ~ enumNames!LabeledResourceType().join(", ") ~ ")");
    if (req.resourceId.length == 0)
      return invalid("Resource ID is required");
    if (req.key.length == 0)
      return invalid("Label key is required");
    auto values = req.values.map!(v => v.strip).filter!(v => v.length > 0).array;
    if (values.length == 0)
      return invalid("At least one label value is required");

    // One label per (resource, key): merge values into an existing label.
    foreach (existing; labels.findByResource(req.tenantId, type, req.resourceId)) {
      if (existing.key != req.key)
        continue;
      foreach (v; values)
        if (!existing.hasValue(v))
          existing.values ~= v;
      existing.update(actor(req.createdBy));
      labels.update(existing);
      return ok(existing.id.value, "Label values merged");
    }

    auto label = Label(req.tenantId);
    label.resourceType = type;
    label.resourceId = req.resourceId;
    label.key = req.key;
    label.values = values;
    label.createdBy = actor(req.createdBy);
    label.updatedBy = label.createdBy;

    labels.save(label);
    return created(label.id.value, "Label created");
  }

  UsecaseResult updateLabel(TenantId tenantId, LabelId id, UpdateLabelRequest req) {
    auto label = labels.findById(tenantId, id);
    if (label.isNull)
      return notFound("Label");
    auto values = req.values.map!(v => v.strip).filter!(v => v.length > 0).array;
    if (values.length == 0)
      return invalid("At least one label value is required");

    label.values = values;
    label.update(actor(req.updatedBy));
    labels.update(label);
    return ok(label.id.value, "Label updated");
  }

  Label getLabel(TenantId tenantId, LabelId id) {
    return labels.findById(tenantId, id);
  }

  Label[] listLabels(TenantId tenantId) {
    return labels.findByTenant(tenantId);
  }

  Label[] listLabels(TenantId tenantId, string resourceType, string resourceId) {
    LabeledResourceType type;
    if (!tryParseEnum!LabeledResourceType(resourceType, type))
      return null;
    return labels.findByResource(tenantId, type, resourceId);
  }

  Label[] listLabelsByKey(TenantId tenantId, string resourceType, string key) {
    LabeledResourceType type;
    if (!tryParseEnum!LabeledResourceType(resourceType, type))
      return null;
    return labels.findByKey(tenantId, type, key);
  }

  UsecaseResult deleteLabel(TenantId tenantId, LabelId id) {
    auto label = labels.findById(tenantId, id);
    if (label.isNull)
      return notFound("Label");

    labels.remove(label);
    return ok(label.id.value, "Label deleted");
  }

  UsecaseResult deleteByResource(TenantId tenantId, string resourceType, string resourceId) {
    LabeledResourceType type;
    if (!tryParseEnum!LabeledResourceType(resourceType, type))
      return invalid("Unknown resource type '" ~ resourceType ~ "'");
    auto count = labels.countByResource(tenantId, type, resourceId);
    labels.removeByResource(tenantId, type, resourceId);
    return ok(resourceId, count.to!string ~ " label(s) deleted");
  }
}
