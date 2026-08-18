/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.usecases.labels;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage labels (tags) on BTP resources.
interface IManageLabelsUseCase { 

  UsecaseResult createLabel(CreateLabelRequest req);
  UsecaseResult updateLabel(TenantId tenantId, LabelId id, UpdateLabelRequest req);
  Label getLabel(TenantId tenantId, LabelId id);
  Label[] listLabels(TenantId tenantId, string resourceType, string resourceId);
  Label[] listLabelsByKey(TenantId tenantId, string resourceType, string key);
  UsecaseResult deleteLabel(TenantId tenantId, LabelId id);
  UsecaseResult deleteByResource(TenantId tenantId, string resourceType, string resourceId);

}
