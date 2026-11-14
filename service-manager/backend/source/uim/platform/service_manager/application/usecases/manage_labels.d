/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.usecases.manage_labels;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageLabelsUseCase : IManageLabels {
  protected ILabelRepository labels;
  protected ResourceDirectory directory;

  this(ILabelRepository labels, ResourceDirectory directory) {
    this.labels = labels;
    this.directory = directory;
  }

  Label[] listLabels(TenantId tenantId) {
    return labels.findAll(tenantId);
  }

  Label[] labelsOf(TenantId tenantId, ResourceType type, string resourceId) {
    return labels.findByResource(tenantId, type, resourceId);
  }

  Label getLabel(TenantId tenantId, LabelId id) {
    return labels.findById(tenantId, id).required("Label '" ~ id.value ~ "'");
  }

  Label createLabel(CreateLabelRequest r) {
    Label l;
    stampCreated!(Label, LabelId)(l, r.tenantId, r.actor, r.id);
    if (labels.existsById(r.tenantId, l.id))
      throw ServiceManagerException.conflict("Label '" ~ l.id.value ~ "' already exists");
    l.resourceType = parseDomainEnum!ResourceType(r.resourceType, "resourceType");
    l.resourceId = r.resourceId.strip;
    l.key = r.key;
    l.value = r.value;
    l.validate();
    if (!directory.exists(r.tenantId, l.resourceType, l.resourceId))
      throw ServiceManagerException.notFound(cast(string) l.resourceType ~ " '" ~ l.resourceId ~ "'");
    foreach (other; labels.findByResource(r.tenantId, l.resourceType, l.resourceId))
      if (other.key == l.key)
        throw ServiceManagerException.conflict("Resource already has a label '" ~ l.key ~ "'");
    labels.save(l);
    return l;
  }

  Label updateLabel(UpdateLabelRequest r) {
    auto l = getLabel(r.tenantId, r.id);
    r.value.applyTo(l.value);
    l.validate();
    stampUpdated(l, r.actor);
    labels.save(l);
    return l;
  }

  void deleteLabel(TenantId tenantId, LabelId id) {
    getLabel(tenantId, id);
    labels.removeById(tenantId, id);
  }
}
