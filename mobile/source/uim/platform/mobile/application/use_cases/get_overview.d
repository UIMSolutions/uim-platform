/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.get_overview;

import uim.platform.mobile.domain.ports.mobile_app_repository;
import uim.platform.mobile.domain.ports.device_registration_repository;
import uim.platform.mobile.domain.ports.push_notification_repository;
import uim.platform.mobile.domain.ports.usage_report_repository;
import uim.platform.mobile.domain.ports.user_session_repository;
import uim.platform.mobile.domain.ports.client_log_repository;
import uim.platform.mobile.domain.types;
import uim.platform.mobile.application.dto;

class GetOverviewUseCase : UIMUseCase {
    private MobileAppRepository appRepo;
    private DeviceRegistrationRepository deviceRepo;
    private PushNotificationRepository pushNotifRepo;
    private UsageReportRepository usageRepo;
    private UserSessionRepository sessionRepo;
    private ClientLogRepository logRepo;

    this(
        MobileAppRepository appRepo,
        DeviceRegistrationRepository deviceRepo,
        PushNotificationRepository pushNotifRepo,
        UsageReportRepository usageRepo,
        UserSessionRepository sessionRepo,
        ClientLogRepository logRepo,
    ) {
        this.appRepo = appRepo;
        this.deviceRepo = deviceRepo;
        this.pushNotifRepo = pushNotifRepo;
        this.usageRepo = usageRepo;
        this.sessionRepo = sessionRepo;
        this.logRepo = logRepo;
    }

    OverviewSummary getSummary(TenantId tenantId) {
        OverviewSummary s;
        s.totalApps = appRepo.countByTenant(tenantId);
        s.totalDevices = deviceRepo.countByTenant(tenantId);
        s.totalPushNotifications = pushNotifRepo.countByTenant(tenantId);
        s.totalPushRegistrations = 0;
        s.totalConfigurations = 0;
        s.totalFeatureFlags = 0;
        s.totalResources = 0;
        s.totalVersions = 0;
        s.totalUsageReports = usageRepo.countByTenant(tenantId);
        s.totalOfflineStores = 0;
        s.totalActiveSessions = sessionRepo.countByTenant(tenantId);
        s.totalLogEntries = logRepo.countByTenant(tenantId);
        return s;
    }
}
