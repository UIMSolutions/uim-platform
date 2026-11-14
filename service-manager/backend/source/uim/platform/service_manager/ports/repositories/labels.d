/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.ports.repositories.labels;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface ILabelRepository : IEntityRepository!(Label, LabelId) {
  Label[] findByResource(TenantId tenantId, ResourceType type, string resourceId);
  /// Remove all labels of a resource; returns the number removed.
  size_t removeByResource(TenantId tenantId, ResourceType type, string resourceId);
}
