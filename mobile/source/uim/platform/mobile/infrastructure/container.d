/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.container;

import uim.platform.mobile.infrastructure.config;

// Repositories
import uim.platform.mobile.infrastructure.persistence.memory.mobile_apps;
import uim.platform.mobile.infrastructure.persistence.memory.device_registrations;
import uim.platform.mobile.infrastructure.persistence.memory.push_notifications;
import uim.platform.mobile.infrastructure.persistence.memory.push_registrations;
import uim.platform.mobile.infrastructure.persistence.memory.app_configurations;
import uim.platform.mobile.infrastructure.persistence.memory.feature_restrictions;
import uim.platform.mobile.infrastructure.persistence.memory.client_resources;
import uim.platform.mobile.infrastructure.persistence.memory.app_versions;
import uim.platform.mobile.infrastructure.persistence.memory.usage_reports;
import uim.platform.mobile.infrastructure.persistence.memory.offline_stores;
import uim.platform.mobile.infrastructure.persistence.memory.user_sessions;
import uim.platform.mobile.infrastructure.persistence.memory.client_logs;

// Use Cases
import uim.platform.mobile.application.usecases.manage.mobile_apps;
import uim.platform.mobile.application.usecases.manage.device_registrations;
import uim.platform.mobile.application.usecases.manage.push_notifications;
import uim.platform.mobile.application.usecases.manage.push_registrations;
import uim.platform.mobile.application.usecases.manage.app_configurations;
import uim.platform.mobile.application.usecases.manage.feature_restrictions;
import uim.platform.mobile.application.usecases.manage.client_resources;
import uim.platform.mobile.application.usecases.manage.app_versions;
import uim.platform.mobile.application.usecases.manage.usage_reports;
import uim.platform.mobile.application.usecases.manage.offline_stores;
import uim.platform.mobile.application.usecases.manage.user_sessions;
import uim.platform.mobile.application.usecases.manage.client_logs;
import uim.platform.mobile.application.usecases.get_overview;

// Controllers
import uim.platform.mobile.presentation.http.controllers.mobile_app;
import uim.platform.mobile.presentation.http.controllers.device_registration;
import uim.platform.mobile.presentation.http.controllers.push_notification;
import uim.platform.mobile.presentation.http.controllers.push_registration;
import uim.platform.mobile.presentation.http.controllers.app_configuration;
import uim.platform.mobile.presentation.http.controllers.feature_restriction;
import uim.platform.mobile.presentation.http.controllers.client_resource;
import uim.platform.mobile.presentation.http.controllers.app_version;
import uim.platform.mobile.presentation.http.controllers.usage_report;
import uim.platform.mobile.presentation.http.controllers.offline_store;
import uim.platform.mobile.presentation.http.controllers.user_session;
import uim.platform.mobile.presentation.http.controllers.client_log;
import uim.platform.mobile.presentation.http.controllers.overview;
import uim.platform.mobile.presentation.http.controllers.health;

struct Container {
  // Repositories (driven adapters)
  MemoryMobileAppRepository appRepo;
  MemoryDeviceRegistrationRepository deviceRepo;
  MemoryPushNotificationRepository pushNotifRepo;
  MemoryPushRegistrationRepository pushRegRepo;
  MemoryAppConfigurationRepository configRepo;
  MemoryFeatureRestrictionRepository featureRepo;
  MemoryClientResourceRepository resourceRepo;
  MemoryAppVersionRepository versionRepo;
  MemoryUsageReportRepository usageRepo;
  MemoryOfflineStoreRepository offlineRepo;
  MemoryUserSessionRepository sessionRepo;
  MemoryClientLogRepository logRepo;

  // Use cases (application layer)
  ManageMobileAppsUseCase manageApps;
  ManageDeviceRegistrationsUseCase manageDevices;
  ManagePushNotificationsUseCase managePushNotifs;
  ManagePushRegistrationsUseCase managePushRegs;
  ManageAppConfigurationsUseCase manageConfigs;
  ManageFeatureRestrictionsUseCase manageFeatures;
  ManageClientResourcesUseCase manageResources;
  ManageAppVersionsUseCase manageVersions;
  ManageUsageReportsUseCase manageUsage;
  ManageOfflineStoresUseCase manageOffline;
  ManageUserSessionsUseCase manageSessions;
  ManageClientLogsUseCase manageLogs;
  GetOverviewUseCase getOverview;

  // Controllers (driving adapters)
  MobileAppController mobileAppController;
  DeviceRegistrationController deviceRegistrationController;
  PushNotificationController pushNotificationController;
  PushRegistrationController pushRegistrationController;
  AppConfigurationController appConfigurationController;
  FeatureRestrictionController featureRestrictionController;
  ClientResourceController clientResourceController;
  AppVersionController appVersionController;
  UsageReportController usageReportController;
  OfflineStoreController offlineStoreController;
  UserSessionController userSessionController;
  ClientLogController clientLogController;
  OverviewController overviewController;
  HealthController healthController;
}

Container buildContainer(AppConfig config) {
  Container c;

  // Infrastructure adapters
  c.appRepo = new MemoryMobileAppRepository();
  c.deviceRepo = new MemoryDeviceRegistrationRepository();
  c.pushNotifRepo = new MemoryPushNotificationRepository();
  c.pushRegRepo = new MemoryPushRegistrationRepository();
  c.configRepo = new MemoryAppConfigurationRepository();
  c.featureRepo = new MemoryFeatureRestrictionRepository();
  c.resourceRepo = new MemoryClientResourceRepository();
  c.versionRepo = new MemoryAppVersionRepository();
  c.usageRepo = new MemoryUsageReportRepository();
  c.offlineRepo = new MemoryOfflineStoreRepository();
  c.sessionRepo = new MemoryUserSessionRepository();
  c.logRepo = new MemoryClientLogRepository();

  // Application use cases
  c.manageApps = new ManageMobileAppsUseCase(c.appRepo);
  c.manageDevices = new ManageDeviceRegistrationsUseCase(c.deviceRepo);
  c.managePushNotifs = new ManagePushNotificationsUseCase(c.pushNotifRepo);
  c.managePushRegs = new ManagePushRegistrationsUseCase(c.pushRegRepo);
  c.manageConfigs = new ManageAppConfigurationsUseCase(c.configRepo);
  c.manageFeatures = new ManageFeatureRestrictionsUseCase(c.featureRepo);
  c.manageResources = new ManageClientResourcesUseCase(c.resourceRepo);
  c.manageVersions = new ManageAppVersionsUseCase(c.versionRepo);
  c.manageUsage = new ManageUsageReportsUseCase(c.usageRepo);
  c.manageOffline = new ManageOfflineStoresUseCase(c.offlineRepo);
  c.manageSessions = new ManageUserSessionsUseCase(c.sessionRepo);
  c.manageLogs = new ManageClientLogsUseCase(c.logRepo);
  c.getOverview = new GetOverviewUseCase(c.appRepo, c.deviceRepo, c.pushNotifRepo, c.usageRepo, c.sessionRepo, c.logRepo);

  // Presentation controllers
  c.mobileAppController = new MobileAppController(c.manageApps);
  c.deviceRegistrationController = new DeviceRegistrationController(c.manageDevices);
  c.pushNotificationController = new PushNotificationController(c.managePushNotifs);
  c.pushRegistrationController = new PushRegistrationController(c.managePushRegs);
  c.appConfigurationController = new AppConfigurationController(c.manageConfigs);
  c.featureRestrictionController = new FeatureRestrictionController(c.manageFeatures);
  c.clientResourceController = new ClientResourceController(c.manageResources);
  c.appVersionController = new AppVersionController(c.manageVersions);
  c.usageReportController = new UsageReportController(c.manageUsage);
  c.offlineStoreController = new OfflineStoreController(c.manageOffline);
  c.userSessionController = new UserSessionController(c.manageSessions);
  c.clientLogController = new ClientLogController(c.manageLogs);
  c.overviewController = new OverviewController(c.getOverview);
  c.healthController = new HealthController("mobile");

  return c;
}
