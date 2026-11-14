/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.services.label;

import uim.platform.management;

mixin(ShowModule!());

@safe:

class LabelApi : ILabelApi {
  protected IManageLabelsUseCase usecase;

  this(IManageLabelsUseCase usecase) {
    this.usecase = usecase;
  }

  Json listLabels(string tenantId, string resourceType, string resourceId, string key) {
    Label[] items;
    if (resourceType.length > 0 && resourceId.length > 0)
      items = usecase.listLabels(tenant(tenantId), resourceType, resourceId);
    else if (resourceType.length > 0 && key.length > 0)
      items = usecase.listLabelsByKey(tenant(tenantId), resourceType, key);
    else
      items = usecase.listLabels(tenant(tenantId));
    return collectionOf(items);
  }

  Json getLabel(string tenantId, string _id) {
    auto id = _id;
    return entityOrNotFound(usecase.getLabel(tenant(tenantId), LabelId(id)), "Label");
  }
}
