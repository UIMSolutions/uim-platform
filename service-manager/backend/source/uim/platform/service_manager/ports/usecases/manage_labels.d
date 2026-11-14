/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.ports.usecases.manage_labels;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface IManageLabels {
  Label[] listLabels(TenantId tenantId);
  Label[] labelsOf(TenantId tenantId, ResourceType type, string resourceId);
  Label getLabel(TenantId tenantId, LabelId id);
  Label createLabel(CreateLabelRequest request);
  Label updateLabel(UpdateLabelRequest request);
  void deleteLabel(TenantId tenantId, LabelId id);
}
