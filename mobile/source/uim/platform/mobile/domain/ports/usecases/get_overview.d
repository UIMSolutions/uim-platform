/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.usecases.get_overview;
// import uim.platform.mobile.domain.ports.repositories.mobile_apps;
// import uim.platform.mobile.domain.ports.repositories.device_registrations;
// import uim.platform.mobile.domain.ports.repositories.push_notifications;
// import uim.platform.mobile.domain.ports.repositories.usage_reports;
// import uim.platform.mobile.domain.ports.repositories.user_sessions;
// import uim.platform.mobile.domain.ports.repositories.client_logs;

// import uim.platform.mobile.application.dto;
import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
interface IGetOverviewUseCase { 

    OverviewSummary getSummary(TenantId tenantId);
    
}
