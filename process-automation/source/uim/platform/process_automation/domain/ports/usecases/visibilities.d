/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.usecases.visibilities;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
interface IManageVisibilitiesUseCase {
    
    CommandResult createVisibility(CreateVisibilityRequest r);
    Visibility getVisibility(TenantId tenantId, VisibilityId visibilityId);
    Visibility[] listVisibilities(TenantId tenantId);
    CommandResult updateVisibility(UpdateVisibilityRequest r);
    CommandResult deleteVisibility(TenantId tenantId, VisibilityId visibilityId);

}
