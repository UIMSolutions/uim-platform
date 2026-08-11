/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.ports.usecases.ui_components;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface IManageUIComponentsUseCase { 

    UIComponent getUIComponent(TenantId tenantId, UIComponentId id);
    UIComponent[] listUIComponents(TenantId tenantId);
    CommandResult createUIComponent(UIComponentDTO dto);
    CommandResult updateUIComponent(UIComponentDTO dto);
    CommandResult deleteUIComponent(TenantId tenantId, UIComponentId id);

}

