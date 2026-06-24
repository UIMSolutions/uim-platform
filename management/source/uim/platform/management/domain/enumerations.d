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

GlobalAccountStatus toGlobalAccountStatus(string value) {
  mixin(toEnumSwitch("GlobalAccountStatus", "active"));
}

GlobalAccountStatus[] toGlobalAccountStatus(string[] values) {
  return values.map!(v => v.toGlobalAccountStatus).array;
}

string toString(GlobalAccountStatus value) {
  return value.to!string();
}

string[] toString(GlobalAccountStatus[] values) {
  return values.map!(v => v.toString).array;
}
/// 
unittest {
  mixin(ShowTest!("GlobalAccountStatus"));

  assert("active".toGlobalAccountStatus == GlobalAccountStatus.active);
  assert("suspended".toGlobalAccountStatus == GlobalAccountStatus.suspended);
  assert("terminated".toGlobalAccountStatus == GlobalAccountStatus.terminated);
  assert("migrating".toGlobalAccountStatus == GlobalAccountStatus.migrating);

  assert(GlobalAccountStatus.active.toString == "active");
  assert(GlobalAccountStatus.suspended.toString == "suspended");
  assert(GlobalAccountStatus.terminated.toString == "terminated");
  assert(GlobalAccountStatus.migrating.toString == "migrating");

  assert(["active", "suspended"].toGlobalAccountStatus == [
      GlobalAccountStatus.active, GlobalAccountStatus.suspended
    ]);
  assert([GlobalAccountStatus.active, GlobalAccountStatus.suspended].toString == [
      "active", "suspended"
    ]);
}

/// License type for a global account.
enum LicenseType {
  enterprise,
  trial,
  partner,
  internal,
}

LicenseType toLicenseType(string value) {
  mixin(toEnumSwitch("LicenseType", "enterprise"));
}

LicenseType[] toLicenseType(string[] values) {
  return values.map!(v => v.toLicenseType).array;
}

string toString(LicenseType value) {
  return value.to!string();
}

string[] toString(LicenseType[] values) {
  return values.map!(v => v.toString).array;
}
///
unittest {
  mixin(ShowTest!("LicenseType"));

  assert("enterprise".toLicenseType == LicenseType.enterprise);
  assert("trial".toLicenseType == LicenseType.trial);
  assert("partner".toLicenseType == LicenseType.partner);
  assert("internal".toLicenseType == LicenseType.internal);

  assert(LicenseType.enterprise.toString == "enterprise");
  assert(LicenseType.trial.toString == "trial");
  assert(LicenseType.partner.toString == "partner");
  assert(LicenseType.internal.toString == "internal");

  assert(["enterprise", "trial"].toLicenseType == [
      LicenseType.enterprise, LicenseType.trial
    ]);
  assert([LicenseType.enterprise, LicenseType.trial].toString == [
      "enterprise", "trial"
    ]);
}

/// Status of a directory entity.
enum DirectoryStatus {
  active,
  inactive,
  deleting,
}

DirectoryStatus toDirectoryStatus(string value) {
  mixin(toEnumSwitch("DirectoryStatus", "active"));
}

DirectoryStatus[] toDirectoryStatus(string[] values) {
  return values.map!(v => v.toDirectoryStatus).array;
}

string toString(DirectoryStatus value) {
  return value.to!string();
}

string[] toString(DirectoryStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("DirectoryStatus"));

  assert("active".toDirectoryStatus == DirectoryStatus.active);
  assert("inactive".toDirectoryStatus == DirectoryStatus.inactive);
  assert("deleting".toDirectoryStatus == DirectoryStatus.deleting);
  assert("unknown".toDirectoryStatus == DirectoryStatus.active); // default

  assert(DirectoryStatus.active.toString == "active");
  assert(DirectoryStatus.inactive.toString == "inactive");
  assert(DirectoryStatus.deleting.toString == "deleting");

  assert(["active", "inactive"].toDirectoryStatus == [
      DirectoryStatus.active, DirectoryStatus.inactive
    ]);
  assert([DirectoryStatus.active, DirectoryStatus.inactive].toString == [
      "active", "inactive"
    ]);
}

/// Type of a directory.
enum DirectoryType {
  default_,
  ldap,
  scim,
  custom,
}

DirectoryType toDirectoryType(string value) {
  switch (value.toLower()) {
  case "default":
    return DirectoryType.default_;
  case "ldap":
    return DirectoryType.ldap;
  case "scim":
    return DirectoryType.scim;
  case "custom":
    return DirectoryType.custom;
  default:
    return DirectoryType.default_; // default
  }
}

DirectoryType[] toDirectoryType(string[] values) {
  return values.map!(v => v.toDirectoryType).array;
}

string toString(DirectoryType value) {
  return value.to!string();
}

string[] toString(DirectoryType[] values) {
  return values.map!(v => v.toString).array;
}
///
unittest {
  mixin(ShowTest!("DirectoryType"));

  assert("default".toDirectoryType == DirectoryType.default_);
  assert("ldap".toDirectoryType == DirectoryType.ldap);
  assert("scim".toDirectoryType == DirectoryType.scim);
  assert("custom".toDirectoryType == DirectoryType.custom);
  assert("unknown".toDirectoryType == DirectoryType.default_);

  assert(DirectoryType.default_.toString == "default_");
  assert(DirectoryType.ldap.toString == "ldap");
  assert(DirectoryType.scim.toString == "scim");
  assert(DirectoryType.custom.toString == "custom");

  assert(["default", "ldap"].toDirectoryType == [
      DirectoryType.default_, DirectoryType.ldap
    ]);
  assert([DirectoryType.default_, DirectoryType.ldap].toString == [
      "default_", "ldap"
    ]);
}

/// Features enabled on a directory.
enum DirectoryFeature {
  default_,
  entitlements,
  authorizations,
}

DirectoryFeature toDirectoryFeature(string value) {
  switch (value.toLower()) {
  case "default":
    return DirectoryFeature.default_;
  case "entitlements":
    return DirectoryFeature.entitlements;
  case "authorizations":
    return DirectoryFeature.authorizations;
  default:
    return DirectoryFeature.default_; // default
  }
}

DirectoryFeature[] toDirectoryFeature(string[] values) {
  return values.map!(v => v.toDirectoryFeature).array;
}

string toString(DirectoryFeature value) {
  return value.to!string();
}

string[] toString(DirectoryFeature[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("DirectoryFeature"));

  assert("default".toDirectoryFeature == DirectoryFeature.default_);
  assert("entitlements".toDirectoryFeature == DirectoryFeature.entitlements);
  assert("authorizations".toDirectoryFeature == DirectoryFeature.authorizations);
  assert("unknown".toDirectoryFeature == DirectoryFeature.default_);

  assert(DirectoryFeature.default_.toString == "default_");
  assert(DirectoryFeature.entitlements.toString == "entitlements");
  assert(DirectoryFeature.authorizations.toString == "authorizations");

  assert(["default", "entitlements"].toDirectoryFeature == [
      DirectoryFeature.default_, DirectoryFeature.entitlements
    ]);
  assert([DirectoryFeature.default_, DirectoryFeature.entitlements].toString == [
      "default_", "entitlements"
    ]);
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

SubaccountStatus toSubaccountStatus(string value) {
  mixin(toEnumSwitch("SubaccountStatus", "active"));
}

SubaccountStatus[] toSubaccountStatus(string[] values) {
  return values.map!(v => v.toSubaccountStatus).array;
}

string toString(SubaccountStatus value) {
  return value.to!string();
}

string[] toString(SubaccountStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("SubaccountStatus"));

  assert("active".toSubaccountStatus == SubaccountStatus.active);
  assert("suspended".toSubaccountStatus == SubaccountStatus.suspended);
  assert("creating".toSubaccountStatus == SubaccountStatus.creating);
  assert("updating".toSubaccountStatus == SubaccountStatus.updating);
  assert("deleting".toSubaccountStatus == SubaccountStatus.deleting);
  assert("moveInProgress".toSubaccountStatus == SubaccountStatus.moveInProgress);
  assert("moveFailed".toSubaccountStatus == SubaccountStatus.moveFailed);
  assert("unknown".toSubaccountStatus == SubaccountStatus.active); // default

  assert(SubaccountStatus.active.toString == "active");
  assert(SubaccountStatus.suspended.toString == "suspended");
  assert(SubaccountStatus.creating.toString == "creating");
  assert(SubaccountStatus.updating.toString == "updating");
  assert(SubaccountStatus.deleting.toString == "deleting");
  assert(SubaccountStatus.moveInProgress.toString == "moveInProgress");
  assert(SubaccountStatus.moveFailed.toString == "moveFailed");

  assert(["active", "suspended"].toSubaccountStatus == [
      SubaccountStatus.active, SubaccountStatus.suspended
    ]);
  assert([SubaccountStatus.active, SubaccountStatus.suspended].toString == [
      "active", "suspended"
    ]);
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

SubaccountUsage toSubaccountUsage(string value) {
  mixin(toEnumSwitch("SubaccountUsage", "unset"));
}

SubaccountUsage[] toSubaccountUsage(string[] values) {
  return values.map!(v => v.toSubaccountUsage).array;
}

string toString(SubaccountUsage value) {
  return value.to!string();
}

string[] toString(SubaccountUsage[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("SubaccountUsage"));

  assert("unset".toSubaccountUsage == SubaccountUsage.unset);
  assert("production".toSubaccountUsage == SubaccountUsage.production);
  assert("development".toSubaccountUsage == SubaccountUsage.development);
  assert("test".toSubaccountUsage == SubaccountUsage.test);
  assert("staging".toSubaccountUsage == SubaccountUsage.staging);
  assert("demo".toSubaccountUsage == SubaccountUsage.demo);
  assert("unknown".toSubaccountUsage == SubaccountUsage.unset); // default

  assert(SubaccountUsage.unset.toString == "unset");
  assert(SubaccountUsage.production.toString == "production");
  assert(SubaccountUsage.development.toString == "development");
  assert(SubaccountUsage.test.toString == "test");
  assert(SubaccountUsage.staging.toString == "staging");
  assert(SubaccountUsage.demo.toString == "demo");

  assert(["unset", "production"].toSubaccountUsage == [
      SubaccountUsage.unset, SubaccountUsage.production
    ]);
  assert([SubaccountUsage.unset, SubaccountUsage.production].toString == [
      "unset", "production"
    ]);
}

/// Status of an entitlement assignment.
enum EntitlementStatus {
  active,
  pending,
  revoked,
  expired,
}

EntitlementStatus toEntitlementStatus(string value) {
  mixin(toEnumSwitch("EntitlementStatus", "active"));
}

EntitlementStatus[] toEntitlementStatus(string[] values) {
  return values.map!(v => v.toEntitlementStatus).array;
}

string toString(EntitlementStatus value) {
  return value.to!string();
}

string[] toString(EntitlementStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("EntitlementStatus"));

  assert("active".toEntitlementStatus == EntitlementStatus.active);
  assert("pending".toEntitlementStatus == EntitlementStatus.pending);
  assert("revoked".toEntitlementStatus == EntitlementStatus.revoked);
  assert("expired".toEntitlementStatus == EntitlementStatus.expired);
  assert("unknown".toEntitlementStatus == EntitlementStatus.active); // default

  assert(EntitlementStatus.active.toString == "active");
  assert(EntitlementStatus.pending.toString == "pending");
  assert(EntitlementStatus.revoked.toString == "revoked");
  assert(EntitlementStatus.expired.toString == "expired");

  assert(["active", "pending"].toEntitlementStatus == [
      EntitlementStatus.active, EntitlementStatus.pending
    ]);
  assert([EntitlementStatus.active, EntitlementStatus.pending].toString == [
      "active", "pending"
    ]);
}

/// Category of a service plan.
enum ServicePlanCategory {
  service,
  application,
  environment,
  elasticService,
}

ServicePlanCategory toServicePlanCategory(string value) {
  mixin(toEnumSwitch("ServicePlanCategory", "service"));
}

ServicePlanCategory[] toServicePlanCategory(string[] values) {
  return values.map!(v => v.toServicePlanCategory).array;
}

string toString(ServicePlanCategory value) {
  return value.to!string();
}

string[] toString(ServicePlanCategory[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("ServicePlanCategory"));

  assert("service".toServicePlanCategory == ServicePlanCategory.service);
  assert("application".toServicePlanCategory == ServicePlanCategory.application);
  assert("environment".toServicePlanCategory == ServicePlanCategory.environment);
  assert("elasticService".toServicePlanCategory == ServicePlanCategory.elasticService);
  assert("unknown".toServicePlanCategory == ServicePlanCategory.service); // default

  assert(ServicePlanCategory.service.toString == "service");
  assert(ServicePlanCategory.application.toString == "application");
  assert(ServicePlanCategory.environment.toString == "environment");
  assert(ServicePlanCategory.elasticService.toString == "elasticService");

  assert(["service", "application"].toServicePlanCategory == [
      ServicePlanCategory.service, ServicePlanCategory.application
    ]);
  assert([ServicePlanCategory.service, ServicePlanCategory.application].toString == [
      "service", "application"
    ]);
}

/// Status of a service plan. 
enum ServicePlanStatus {
  active,
  deprecated_,
  deleted,
}

ServicePlanStatus toServicePlanStatus(string value) {
  switch (value.toLower()) {
  case "active":
    return ServicePlanStatus.active;
  case "deprecated":
    return ServicePlanStatus.deprecated_;
  case "deleted":
    return ServicePlanStatus.deleted;
  default:
    return ServicePlanStatus.active; // default
  }
}

ServicePlanStatus[] toServicePlanStatus(string[] values) {
  return values.map!(v => v.toServicePlanStatus).array;
}

string toString(ServicePlanStatus value) {
  return value.to!string();
}

string[] toString(ServicePlanStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("ServicePlanStatus"));

  assert("active".toServicePlanStatus == ServicePlanStatus.active);
  assert("deprecated".toServicePlanStatus == ServicePlanStatus.deprecated_);
  assert("deleted".toServicePlanStatus == ServicePlanStatus.deleted);
  assert("unknown".toServicePlanStatus == ServicePlanStatus.active); // default

  assert(ServicePlanStatus.active.toString == "active");
  assert(ServicePlanStatus.deprecated_.toString == "deprecated_");
  assert(ServicePlanStatus.deleted.toString == "deleted");

  assert(["active", "deprecated"].toServicePlanStatus == [
      ServicePlanStatus.active, ServicePlanStatus.deprecated_
    ]);
  assert([ServicePlanStatus.active, ServicePlanStatus.deprecated_].toString == [
      "active", "deprecated_"
    ]);
}

/// Pricing model for a service plan.
enum PricingModel {
  free,
  subscription,
  consumption,
  byol, // bring your own license
}

PricingModel toPricingModel(string value) {
  mixin(toEnumSwitch("PricingModel", "free"));
}

PricingModel[] toPricingModel(string[] values) {
  return values.map!(v => v.toPricingModel).array;
}

string toString(PricingModel value) {
  return value.to!string();
}

string[] toString(PricingModel[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("PricingModel"));

  assert("free".toPricingModel == PricingModel.free);
  assert("subscription".toPricingModel == PricingModel.subscription);
  assert("consumption".toPricingModel == PricingModel.consumption);
  assert("byol".toPricingModel == PricingModel.byol);
  assert("unknown".toPricingModel == PricingModel.free); // default

  assert(PricingModel.free.toString == "free");
  assert(PricingModel.subscription.toString == "subscription");
  assert(PricingModel.consumption.toString == "consumption");
  assert(PricingModel.byol.toString == "byol");

  assert(["free", "subscription"].toPricingModel == [
      PricingModel.free, PricingModel.subscription
    ]);
  assert([PricingModel.free, PricingModel.subscription].toString == [
      "free", "subscription"
    ]);
}

/// Status of a quota definition.
enum QuotaStatus {
  active,
  deprecated_,
  deleted,
}

QuotaStatus toQuotaStatus(string value) {
  switch (value.toLower()) {
  case "active":
    return QuotaStatus.active;
  case "deprecated":
    return QuotaStatus.deprecated_;
  case "deleted":
    return QuotaStatus.deleted;
  default:
    return QuotaStatus.active; // default
  }
}

QuotaStatus[] toQuotaStatus(string[] values) {
  return values.map!(v => v.toQuotaStatus).array;
}

string toString(QuotaStatus value) {
  return value.to!string();
}

string[] toString(QuotaStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("QuotaStatus"));

  assert("active".toQuotaStatus == QuotaStatus.active);
  assert("deprecated".toQuotaStatus == QuotaStatus.deprecated_);
  assert("deleted".toQuotaStatus == QuotaStatus.deleted);
  assert("unknown".toQuotaStatus == QuotaStatus.active); // default

  assert(QuotaStatus.active.toString == "active");
  assert(QuotaStatus.deprecated_.toString == "deprecated_");
  assert(QuotaStatus.deleted.toString == "deleted");

  assert(["active", "deprecated"].toQuotaStatus == [
      QuotaStatus.active, QuotaStatus.deprecated_
    ]);
  assert([QuotaStatus.active, QuotaStatus.deprecated_].toString == [
      "active", "deprecated_"
    ]);
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

EnvironmentStatus toEnvironmentStatus(string value) {
  mixin(toEnumSwitch("EnvironmentStatus", "creating"));
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

SubscriptionStatus toSubscriptionStatus(string value) {
  mixin(toEnumSwitch("SubscriptionStatus", "subscribed"));
}

SubscriptionStatus[] toSubscriptionStatus(string[] values) {
  return values.map!(v => v.toSubscriptionStatus).array;
}

string toString(SubscriptionStatus value) {
  return value.to!string();
}

string[] toString(SubscriptionStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("SubscriptionStatus"));

  assert("subscribed".toSubscriptionStatus == SubscriptionStatus.subscribed);
  assert("subscribing".toSubscriptionStatus == SubscriptionStatus.subscribing);
  assert("unsubscribing".toSubscriptionStatus == SubscriptionStatus.unsubscribing);
  assert("unsubscribed".toSubscriptionStatus == SubscriptionStatus.unsubscribed);
  assert("error".toSubscriptionStatus == SubscriptionStatus.error);
  assert("suspended".toSubscriptionStatus == SubscriptionStatus.suspended);
  assert("unknown".toSubscriptionStatus == SubscriptionStatus.subscribed); // default

  assert(SubscriptionStatus.subscribed.toString == "subscribed");
  assert(SubscriptionStatus.subscribing.toString == "subscribing");
  assert(SubscriptionStatus.unsubscribing.toString == "unsubscribing");
  assert(SubscriptionStatus.unsubscribed.toString == "unsubscribed");
  assert(SubscriptionStatus.error.toString == "error");
  assert(SubscriptionStatus.suspended.toString == "suspended");

  assert(["subscribed", "subscribing"].toSubscriptionStatus == [
      SubscriptionStatus.subscribed, SubscriptionStatus.subscribing
    ]);
  assert([SubscriptionStatus.subscribed, SubscriptionStatus.subscribing].toString == [
      "subscribed", "subscribing"
    ]);
}

/// Status of a service instance.
enum ServiceInstanceStatus {
  creating,
  ready,
  failed,
  deleting,
  updating,
}

ServiceInstanceStatus toServiceInstanceStatus(string value) {
  mixin(toEnumSwitch("ServiceInstanceStatus", "creating"));
}
ServiceInstanceStatus[] toServiceInstanceStatus(string[] values) {
  return values.map!(v => v.toServiceInstanceStatus).array;
}
string toString(ServiceInstanceStatus value) {
  return value.to!string();
}
string[] toString(ServiceInstanceStatus[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("ServiceInstanceStatus"));

  assert("creating".toServiceInstanceStatus == ServiceInstanceStatus.creating);
  assert("ready".toServiceInstanceStatus == ServiceInstanceStatus.ready);
  assert("failed".toServiceInstanceStatus == ServiceInstanceStatus.failed);
  assert("deleting".toServiceInstanceStatus == ServiceInstanceStatus.deleting);
  assert("updating".toServiceInstanceStatus == ServiceInstanceStatus.updating);
  assert("unknown".toServiceInstanceStatus == ServiceInstanceStatus.creating); // default

  assert(ServiceInstanceStatus.creating.toString == "creating");
  assert(ServiceInstanceStatus.ready.toString == "ready");
  assert(ServiceInstanceStatus.failed.toString == "failed");
  assert(ServiceInstanceStatus.deleting.toString == "deleting");
  assert(ServiceInstanceStatus.updating.toString == "updating");

  assert(["creating", "ready"].toServiceInstanceStatus == [
      ServiceInstanceStatus.creating, ServiceInstanceStatus.ready
    ]);
  assert([ServiceInstanceStatus.creating, ServiceInstanceStatus.ready].toString == [
      "creating", "ready"
    ]);
}

/// Type of environment.
enum EnvironmentType {
  cloudFoundry,
  kyma,
  abap,
  neo,
}

EnvironmentType toEnvironmentType(string value) {
  mixin(toEnumSwitch("EnvironmentType", "cloudFoundry"));
}
EnvironmentType[] toEnvironmentType(string[] values) {
  return values.map!(v => v.toEnvironmentType).array;
}
string toString(EnvironmentType value) {
  return value.to!string();
}
string[] toString(EnvironmentType[] values) {
  return values.map!(v => v.toString()).array;
}
/// 
unittest {
  mixin(ShowTest!("EnvironmentType"));

  assert("cloudFoundry".toEnvironmentType == EnvironmentType.cloudFoundry);
  assert("kyma".toEnvironmentType == EnvironmentType.kyma);
  assert("abap".toEnvironmentType == EnvironmentType.abap);
  assert("neo".toEnvironmentType == EnvironmentType.neo);
  assert("unknown".toEnvironmentType == EnvironmentType.cloudFoundry); // default

  assert(EnvironmentType.cloudFoundry.toString == "cloudFoundry");
  assert(EnvironmentType.kyma.toString == "kyma");
  assert(EnvironmentType.abap.toString == "abap");
  assert(EnvironmentType.neo.toString == "neo");

  assert(["cloudFoundry", "kyma"].toEnvironmentType == [
      EnvironmentType.cloudFoundry, EnvironmentType.kyma
    ]);
  assert([EnvironmentType.cloudFoundry, EnvironmentType.kyma].toString == [
      "cloudFoundry", "kyma"
    ]);
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

EnvironmentEventCategory toEnvironmentEventCategory(string value) {
  mixin(toEnumSwitch("EnvironmentEventCategory", "subaccountLifecycle"));
}
EnvironmentEventCategory[] toEnvironmentEventCategory(string[] values) {
  return values.map!(v => v.toEnvironmentEventCategory).array;
}
string toString(EnvironmentEventCategory value) {
  return value.to!string();
}
string[] toString(EnvironmentEventCategory[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("EnvironmentEventCategory"));

  assert("subaccountLifecycle".toEnvironmentEventCategory == EnvironmentEventCategory.subaccountLifecycle);
  assert("entitlementChange".toEnvironmentEventCategory == EnvironmentEventCategory.entitlementChange);
  assert("environmentLifecycle".toEnvironmentEventCategory == EnvironmentEventCategory.environmentLifecycle);
  assert("subscriptionLifecycle".toEnvironmentEventCategory == EnvironmentEventCategory.subscriptionLifecycle);
  assert("directoryChange".toEnvironmentEventCategory == EnvironmentEventCategory.directoryChange);
  assert("globalAccountChange".toEnvironmentEventCategory == EnvironmentEventCategory.globalAccountChange);
  assert("quotaChange".toEnvironmentEventCategory == EnvironmentEventCategory.quotaChange);
  assert("securityEvent".toEnvironmentEventCategory == EnvironmentEventCategory.securityEvent);
  assert("unknown".toEnvironmentEventCategory == EnvironmentEventCategory.subaccountLifecycle); // default

  assert(EnvironmentEventCategory.subaccountLifecycle.toString == "subaccountLifecycle");
  assert(EnvironmentEventCategory.entitlementChange.toString == "entitlementChange");
  assert(EnvironmentEventCategory.environmentLifecycle.toString == "environmentLifecycle");
  assert(EnvironmentEventCategory.subscriptionLifecycle.toString == "subscriptionLifecycle");
  assert(EnvironmentEventCategory.directoryChange.toString == "directoryChange");
  assert(EnvironmentEventCategory.globalAccountChange.toString == "globalAccountChange");
  assert(EnvironmentEventCategory.quotaChange.toString == "quotaChange");
  assert(EnvironmentEventCategory.securityEvent.toString == "securityEvent");

  assert(["subaccountLifecycle", "entitlementChange"].toEnvironmentEventCategory == [
      EnvironmentEventCategory.subaccountLifecycle, EnvironmentEventCategory.entitlementChange
    ]);
  assert([EnvironmentEventCategory.subaccountLifecycle, EnvironmentEventCategory.entitlementChange].toString == [
      "subaccountLifecycle", "entitlementChange"
    ]);
}


/// Severity of a platform event.
enum EnvironmentEventSeverity {
  info,
  warning,
  error,
  critical,
}

EnvironmentEventSeverity toEnvironmentEventSeverity(string value) {
  mixin(toEnumSwitch("EnvironmentEventSeverity", "info"));
}
EnvironmentEventSeverity[] toEnvironmentEventSeverity(string[] values) {
  return values.map!(v => v.toEnvironmentEventSeverity).array;
}
string toString(EnvironmentEventSeverity value) {
  return value.to!string();
}
string[] toString(EnvironmentEventSeverity[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("EnvironmentEventSeverity"));

  assert("info".toEnvironmentEventSeverity == EnvironmentEventSeverity.info);
  assert("warning".toEnvironmentEventSeverity == EnvironmentEventSeverity.warning);
  assert("error".toEnvironmentEventSeverity == EnvironmentEventSeverity.error);
  assert("critical".toEnvironmentEventSeverity == EnvironmentEventSeverity.critical);
  assert("unknown".toEnvironmentEventSeverity == EnvironmentEventSeverity.info); // default

  assert(EnvironmentEventSeverity.info.toString == "info");
  assert(EnvironmentEventSeverity.warning.toString == "warning");
  assert(EnvironmentEventSeverity.error.toString == "error");
  assert(EnvironmentEventSeverity.critical.toString == "critical");

  assert(["info", "warning"].toEnvironmentEventSeverity == [
      EnvironmentEventSeverity.info, EnvironmentEventSeverity.warning
    ]);
  assert([EnvironmentEventSeverity.info, EnvironmentEventSeverity.warning].toString == [
      "info", "warning" 
    ]);
}

/// Type of labeled resource.
enum LabeledResourceType {
  subaccount,
  globalAccount,
  directory,
  Environment,
  subscription
}

LabeledResourceType toLabeledResourceType(string value) {
  mixin(toEnumSwitch("LabeledResourceType", "subaccount"));
}
LabeledResourceType[] toLabeledResourceType(string[] values) {
  return values.map!(v => v.toLabeledResourceType).array;
}
string toString(LabeledResourceType value) {
  return value.to!string(); 
}
string[] toString(LabeledResourceType[] values) {
  return values.map!(v => v.toString()).array;
}
///
unittest {
  mixin(ShowTest!("LabeledResourceType"));

  assert("subaccount".toLabeledResourceType == LabeledResourceType.subaccount);
  assert("globalAccount".toLabeledResourceType == LabeledResourceType.globalAccount);
  assert("directory".toLabeledResourceType == LabeledResourceType.directory);
  assert("environment".toLabeledResourceType == LabeledResourceType.Environment); 
  assert("subscription".toLabeledResourceType == LabeledResourceType.subscription);
  assert("unknown".toLabeledResourceType == LabeledResourceType.subaccount); //

  assert(LabeledResourceType.subaccount.toString == "subaccount");
  assert(LabeledResourceType.globalAccount.toString == "globalAccount");
  assert(LabeledResourceType.directory.toString == "directory");
  assert(LabeledResourceType.Environment.toString == "Environment");
  assert(LabeledResourceType.subscription.toString == "subscription");  

  assert(["subaccount", "globalAccount"].toLabeledResourceType == [
      LabeledResourceType.subaccount, LabeledResourceType.globalAccount
    ]);
  assert([LabeledResourceType.subaccount, LabeledResourceType.globalAccount].toString == [
      "subaccount", "globalAccount"
    ]);
}