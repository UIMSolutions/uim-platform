module uim.platform.management.domain.enumerations;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
/// Status of a global account.
enum GlobalAccountStatus {
  active,
  suspended,
  terminated,
  migrating,
}
GlobalAccountStatus toGlobalAccountStatus(string s) {
  switch (s.toLower()) {
    case "active": return GlobalAccountStatus.active;
    case "suspended": return GlobalAccountStatus.suspended;
    case "terminated": return GlobalAccountStatus.terminated;
    case "migrating": return GlobalAccountStatus.migrating;
    default: return GlobalAccountStatus.active; // default
  }
}
/// License type for a global account.
enum LicenseType {
  enterprise,
  trial,
  partner,
  internal,
}
LicenseType toLicenseType(string s) {
  switch (s.toLower()) {
    case "enterprise": return LicenseType.enterprise;
    case "trial": return LicenseType.trial;
    case "partner": return LicenseType.partner;
    case "internal": return LicenseType.internal;
    default: return LicenseType.enterprise; // default
  }
}
/// Status of a directory entity.
enum DirectoryStatus {
  active,
  inactive,
  deleting,
}
DirectoryStatus toDirectoryStatus(string s) {
  switch (s.toLower()) {
    case "active": return DirectoryStatus.active;
    case "inactive": return DirectoryStatus.inactive;
    case "deleting": return DirectoryStatus.deleting;
    default: return DirectoryStatus.active; // default
  }
}
/// Type of a directory.
enum DirectoryType {
  default_,
  ldap,
  scim,
  custom,
}
DirectoryType toDirectoryType(string s) {
  switch (s.toLower()) {
    case "default": return DirectoryType.default_;
    case "ldap": return DirectoryType.ldap; 
    case "scim": return DirectoryType.scim;
    case "custom": return DirectoryType.custom;
    default: return DirectoryType.default_; // default
  }
}

/// Features enabled on a directory.
enum DirectoryFeature {
  default_,
  entitlements,
  authorizations,
}
DirectoryFeature toDirectoryFeature(string s) {
  switch (s.toLower()) {
    case "default": return DirectoryFeature.default_;
    case "entitlements": return DirectoryFeature.entitlements;
    case "authorizations": return DirectoryFeature.authorizations;
    default: return DirectoryFeature.default_; // default
  }
}
/// Status of a subaccount.
enum SubaccountStatus {
  active,
  suspended,
  creating,
  updating,
  deleting,
  moveInProgress,
  moveFailed,
}
SubaccountStatus toSubaccountStatus(string s) {
  switch (s.toLower()) {
    case "active": return SubaccountStatus.active;
    case "suspended": return SubaccountStatus.suspended;
    case "creating": return SubaccountStatus.creating;
    case "updating": return SubaccountStatus.updating;
    case "deleting": return SubaccountStatus.deleting;
    case "moveinprogress": return SubaccountStatus.moveInProgress;
    case "movefailed": return SubaccountStatus.moveFailed;
    default: return SubaccountStatus.active; // default
  }
}
/// Usage type of a subaccount.
enum SubaccountUsage {
  unset,
  production,
  development,
  test,
  staging,
  demo,
}
SubaccountUsage toSubaccountUsage(string s) {
  switch (s.toLower()) {
    case "production": return SubaccountUsage.production;
    case "development": return SubaccountUsage.development;
    case "test": return SubaccountUsage.test;
    case "staging": return SubaccountUsage.staging;
    case "demo": return SubaccountUsage.demo;
    default: return SubaccountUsage.unset;
  }
}
/// Status of an entitlement assignment.
enum EntitlementStatus {
  active,
  pending,
  revoked,
  expired,
}
EntitlementStatus toEntitlementStatus(string s) {
  switch (s.toLower()) {
    case "active": return EntitlementStatus.active;
    case "pending": return EntitlementStatus.pending;
    case "revoked": return EntitlementStatus.revoked;
    case "expired": return EntitlementStatus.expired;
    default: return EntitlementStatus.active; // default
  }
}
/// Category of a service plan.
enum ServicePlanCategory {
  service,
  application,
  environment,
  elasticService,
}
ServicePlanCategory toServicePlanCategory(string s) {
  switch (s.toLower()) {
    case "service": return ServicePlanCategory.service;
    case "application": return ServicePlanCategory.application;
    case "environment": return ServicePlanCategory.environment;
    case "elasticservice": return ServicePlanCategory.elasticService;
    default: return ServicePlanCategory.service; // default
  }
}
/// Status of a service plan. 
enum ServicePlanStatus {
  active,
  deprecated_,
  deleted,
}
ServicePlanStatus toServicePlanStatus(string s) {
  switch (s.toLower()) {
    case "active": return ServicePlanStatus.active;
    case "deprecated": return ServicePlanStatus.deprecated_;
    case "deleted": return ServicePlanStatus.deleted;
    default: return ServicePlanStatus.active; // default
  }
}
/// Pricing model for a service plan.
enum PricingModel {
  free,
  subscription,
  consumption,
  byol, // bring your own license
}
PricingModel toPricingModel(string s) {
  switch (s.toLower()) {
    case "free": return PricingModel.free;
    case "subscription": return PricingModel.subscription;
    case "consumption": return PricingModel.consumption;
    case "byol": return PricingModel.byol;
    default: return PricingModel.free; // default
  }
}
/// Status of a quota definition.
enum QuotaStatus {
  active,
  deprecated_,
  deleted,
}
QuotaStatus toQuotaStatus(string s) {
  switch (s.toLower()) {
    case "active": return QuotaStatus.active;
    case "deprecated": return QuotaStatus.deprecated_;
    case "deleted": return QuotaStatus.deleted;
    default: return QuotaStatus.active; // default
  }
}
/// Status of an environment instance.
enum EnvironmentStatus {
  creating,
  active,
  updating,
  deleting,
  error,
  suspended,
}
EnvironmentStatus toEnvironmentStatus(string s) {
  switch (s.toLower()) {
    case "creating": return EnvironmentStatus.creating;
    case "active": return EnvironmentStatus.active;
    case "updating": return EnvironmentStatus.updating;
    case "deleting": return EnvironmentStatus.deleting;
    case "error": return EnvironmentStatus.error;
    case "suspended": return EnvironmentStatus.suspended;
    default: return EnvironmentStatus.creating; // default
  }
}
/// Status of a subscription.
enum SubscriptionStatus { 
  subscribed,
  subscribing,
  unsubscribing,
  unsubscribed,
  error,
  suspended,
}
SubscriptionStatus toSubscriptionStatus(string s) {
  switch (s.toLower()) {
    case "subscribed": return SubscriptionStatus.subscribed;
    case "subscribing": return SubscriptionStatus.subscribing;
    case "unsubscribing": return SubscriptionStatus.unsubscribing;
    case "unsubscribed": return SubscriptionStatus.unsubscribed;
    case "error": return SubscriptionStatus.error;
    case "suspended": return SubscriptionStatus.suspended;
    default: return SubscriptionStatus.subscribed; // default
  }
}

/// Status of a service instance.
enum ServiceInstanceStatus {
  creating,
  ready,
  failed,
  deleting,
  updating,
}
ServiceInstanceStatus toServiceInstanceStatus(string s) {
  switch (s.toLower()) {
    case "creating": return ServiceInstanceStatus.creating;
    case "ready": return ServiceInstanceStatus.ready;
    case "failed": return ServiceInstanceStatus.failed;
    case "deleting": return ServiceInstanceStatus.deleting;
    case "updating": return ServiceInstanceStatus.updating;
    default: return ServiceInstanceStatus.creating; // default
  }
}
/// Type of environment.
enum EnvironmentType {
  cloudFoundry,
  kyma,
  abap,
  neo,
}
EnvironmentType toEnvironmentType(string s) {
  switch (s.toLower()) {
    case "cloudfoundry": return EnvironmentType.cloudFoundry;
    case "kyma": return EnvironmentType.kyma;
    case "abap": return EnvironmentType.abap;
    case "neo": return EnvironmentType.neo;
    default: return EnvironmentType.cloudFoundry; // default
  }
}

/// Category of a platform event.
enum EnvironmentEventCategory {
  subaccountLifecycle,
  entitlementChange,
  environmentLifecycle,
  subscriptionLifecycle,
  directoryChange,
  globalAccountChange,
  quotaChange,
  securityEvent,
}
EnvironmentEventCategory toEnvironmentEventCategory(string s) {
  switch (s.toLower()) {
    case "subaccountlifecycle": return EnvironmentEventCategory.subaccountLifecycle;
    case "entitlementchange": return EnvironmentEventCategory.entitlementChange;
    case "environmentlifecycle": return EnvironmentEventCategory.environmentLifecycle;
    case "subscriptionlifecycle": return EnvironmentEventCategory.subscriptionLifecycle;
    case "directorychange": return EnvironmentEventCategory.directoryChange;
    case "globalaccountchange": return EnvironmentEventCategory.globalAccountChange;
    case "quotachange": return EnvironmentEventCategory.quotaChange;
    case "securityevent": return EnvironmentEventCategory.securityEvent;
    default: return EnvironmentEventCategory.subaccountLifecycle; // default
  }
}
/// Severity of a platform event.
enum EnvironmentEventSeverity {
  info,
  warning,
  error,
  critical,
}
EnvironmentEventSeverity toEnvironmentEventSeverity(string s) {
  switch (s.toLower()) {
    case "info": return EnvironmentEventSeverity.info;
    case "warning": return EnvironmentEventSeverity.warning;
    case "error": return EnvironmentEventSeverity.error;
    case "critical": return EnvironmentEventSeverity.critical;
    default: return EnvironmentEventSeverity.info; // default
  }
}
/// Type of labeled resource.
enum LabeledResourceType {
  subaccount,
  globalAccount,
  directory,
  Environment,
  subscription
}
LabeledResourceType toLabeledResourceType(string s) {
  switch (s.toLower()) {
    case "subaccount": return LabeledResourceType.subaccount;
    case "globalaccount": return LabeledResourceType.globalAccount;
    case "directory": return LabeledResourceType.directory;
    case "Environment": return LabeledResourceType.Environment;
    case "subscription": return LabeledResourceType.subscription;
    default: return LabeledResourceType.subaccount; // default
  }
}
