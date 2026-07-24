module uim.platform.management.domain.enumerations;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Status of a global account.
enum GlobalAccountStatus {
  /// Default status when the global account status is unknown or not reported.
  active,
  /// The global account is suspended and cannot be used to create subaccounts or access services.
  suspended,
  /// The global account is terminated and cannot be used to create subaccounts or access services.
  terminated,
  /// The global account is in the process of being migrated to a new system or platform.
  migrating,
}

GlobalAccountStatus toGlobalAccountStatus(string value) {
  mixin(EnumSwitch("GlobalAccountStatus", "active"));
}

GlobalAccountStatus[] toGlobalAccountStatuses(string[] values)
  => values.map!toGlobalAccountStatus.array;

string toString(GlobalAccountStatus value)
  => value.to!string;

string[] toStrings(GlobalAccountStatus[] values)
  => values.map!toString.array;
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

  assert(["active", "suspended"].toGlobalAccountStatuses == [
      GlobalAccountStatus.active, GlobalAccountStatus.suspended
    ]);
  assert([GlobalAccountStatus.active, GlobalAccountStatus.suspended].toStrings == [
      "active", "suspended"
    ]);
}

/// License type for a global account.
enum LicenseType {
  /// Default license type when the license type is unknown or not reported.
  enterprise,
  /// Trial license type for a global account.
  trial,
  /// Partner license type for a global account.
  partner,
  /// Internal license type for a global account.
  internal,
}

LicenseType toLicenseType(string value) {
  mixin(EnumSwitch("LicenseType", "enterprise"));
}

LicenseType[] toLicenseTypes(string[] values) {
  return values.map!toLicenseType.array;
}

string toString(LicenseType value) {
  return value.to!string;
}

string[] toStrings(LicenseType[] values) {
  return values.map!toString.array;
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

  assert(["enterprise", "trial"].toLicenseTypes == [
      LicenseType.enterprise, LicenseType.trial
    ]);
  assert([LicenseType.enterprise, LicenseType.trial].toStrings == [
      "enterprise", "trial"
    ]);
}

/// Status of a directory entity.
enum DirectoryStatus {
  /// The directory is active and operational.
  active,
  /// The directory is inactive and not operational.
  inactive,
  /// The directory is in the process of being deleted.
  deleting,
}

DirectoryStatus toDirectoryStatus(string value) {
  mixin(EnumSwitch("DirectoryStatus", "active"));
}

DirectoryStatus[] toDirectoryStatuses(string[] values) {
  return values.map!(v => v.toDirectoryStatus).array;
}

string toString(DirectoryStatus value) {
  return value.to!string;
}

string[] toStrings(DirectoryStatus[] values) {
  return values.map!toString.array;
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

  assert(["active", "inactive"].toDirectoryStatuses == [
      DirectoryStatus.active, DirectoryStatus.inactive
    ]);
  assert([DirectoryStatus.active, DirectoryStatus.inactive].toStrings == [
      "active", "inactive"
    ]);
}

/// Type of a directory.
enum DirectoryType {
  /// Default directory type.
  default_,
  /// LDAP directory type.
  ldap,
  /// SCIM directory type.
  scim,
  /// Custom directory type.
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

DirectoryType[] toDirectoryTypes(string[] values) {
  return values.map!toDirectoryType.array;
}

string toString(DirectoryType value) {
  return value.to!string;
}

string[] toStrings(DirectoryType[] values) {
  return values.map!toString.array;
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

  assert(["default", "ldap"].toDirectoryTypes == [
      DirectoryType.default_, DirectoryType.ldap
    ]);
  assert([DirectoryType.default_, DirectoryType.ldap].toStrings == [
      "default_", "ldap"
    ]);
}

/// Features enabled on a directory.
enum DirectoryFeature {
  /// Default feature when the feature is unknown or not reported.
  default_,
  /// Entitlements feature.
  entitlements,
  /// Authorizations feature.
  authorizations,
}

DirectoryFeature toDirectoryFeature(string value) {
  switch (value.toLower) {
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

DirectoryFeature[] toDirectoryFeatures(string[] values) {
  return values.map!toDirectoryFeature.array;
}

string toString(DirectoryFeature value) {
  return value.to!string;
}

string[] toStrings(DirectoryFeature[] values) {
  return values.map!toString.array;
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

  assert(["default", "entitlements"].toDirectoryFeatures == [
      DirectoryFeature.default_, DirectoryFeature.entitlements
    ]);
  assert([DirectoryFeature.default_, DirectoryFeature.entitlements].toStrings == [
      "default_", "entitlements"
    ]);
}

/// Status of a subaccount.
enum SubaccountStatus {
  /// The subaccount is active and operational.
  active,
  /// The subaccount is suspended and not operational.
  suspended,
  /// The subaccount is in the process of being created.
  creating,
  /// The subaccount is in the process of being updated.
  updating,
  /// The subaccount is in the process of being deleted.
  deleting,
  /// The subaccount is in the process of being moved.
  moveInProgress,
  /// The subaccount move operation has failed.
  moveFailed,
}

SubaccountStatus toSubaccountStatus(string value) {
  mixin(EnumSwitch("SubaccountStatus", "active"));
}

SubaccountStatus[] toSubaccountStatuses(string[] values) {
  return values.map!toSubaccountStatus.array;
}

string toString(SubaccountStatus value) {
  return value.to!string;
}

string[] toStrings(SubaccountStatus[] values) {
  return values.map!toString.array;
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
  assert("".toSubaccountStatus == SubaccountStatus.active); // default

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
  assert([SubaccountStatus.active, SubaccountStatus.suspended].toStrings == [
      "active", "suspended"
    ]);
}

/// Usage type of a subaccount.
enum SubaccountUsage {
  /// The usage type is not set.
  unset,
  /// The subaccount is used for production purposes.
  production,
  /// The subaccount is used for development purposes.
  development,
  /// The subaccount is used for testing purposes.
  test,
  /// The subaccount is used for staging purposes.
  staging,
  /// The subaccount is used for demo purposes.
  demo,
}

SubaccountUsage toSubaccountUsage(string value) {
  mixin(EnumSwitch("SubaccountUsage", "unset"));
}

SubaccountUsage[] toSubaccountUsages(string[] values) {
  return values.map!toSubaccountUsage.array;
}

string toString(SubaccountUsage value) {
  return value.to!string;
}

string[] toStrings(SubaccountUsage[] values) {
  return values.map!toString.array;
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
  assert([SubaccountUsage.unset, SubaccountUsage.production].toStrings == [
      "unset", "production"
    ]);
}

/// Status of an entitlement assignment.
enum EntitlementStatus {
  active, // Default status when the entitlement status is unknown or not reported.
  pending, // The entitlement is pending approval or activation.
  revoked, // The entitlement has been revoked and is no longer valid.
  expired, // The entitlement has expired and is no longer valid.
}

EntitlementStatus toEntitlementStatus(string value) {
  mixin(EnumSwitch("EntitlementStatus", "active"));
}

EntitlementStatus[] toEntitlementStatuses(string[] values) {
  return values.map!(v => v.toEntitlementStatus).array;
}

string toString(EntitlementStatus value) {
  return value.to!string;
}

string[] toStrings(EntitlementStatus[] values) {
  return values.map!toString.array;
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

  assert(["active", "pending"].toEntitlementStatuses == [
      EntitlementStatus.active, EntitlementStatus.pending
    ]);
  assert([EntitlementStatus.active, EntitlementStatus.pending].toStrings == [
      "active", "pending"
    ]);
}

/// Category of a service plan.
enum ServicePlanCategory {
  /// Default category when the service plan category is unknown or not reported.
  service,
  /// The service plan is categorized as an application.
  application,
  /// The service plan is categorized as an environment.
  environment,
  /// The service plan is categorized as an elastic service.
  elasticService,
}

ServicePlanCategory toServicePlanCategory(string value) {
  mixin(EnumSwitch("ServicePlanCategory", "service"));
}

ServicePlanCategory[] toServicePlanCategories(string[] values) {
  return values.map!toServicePlanCategory.array;
}

string toString(ServicePlanCategory value) {
  return value.to!string;
}

string[] toStrings(ServicePlanCategory[] values) {
  return values.map!toString.array;
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

  assert(["service", "application"].toServicePlanCategories == [
      ServicePlanCategory.service, ServicePlanCategory.application
    ]);
  assert([ServicePlanCategory.service, ServicePlanCategory.application].toStrings == [
      "service", "application"
    ]);
}

/// Status of a service plan. 
enum ServicePlanStatus {
  /// Default status when the service plan status is unknown or not reported.
  active,
  /// The service plan is deprecated and may be removed in the future.
  deprecated_,
  /// The service plan is deleted and no longer available.
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

ServicePlanStatus[] toServicePlanStatuses(string[] values) {
  return values.map!(v => v.toServicePlanStatus).array;
}

string toString(ServicePlanStatus value) {
  return value.to!string;
}

string[] toStrings(ServicePlanStatus[] values) {
  return values.map!toString.array;
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

  assert(["active", "deprecated"].toServicePlanStatuses == [
      ServicePlanStatus.active, ServicePlanStatus.deprecated_
    ]);
  assert([ServicePlanStatus.active, ServicePlanStatus.deprecated_].toStrings == [
      "active", "deprecated_"
    ]);
}

/// Pricing model for a service plan.
enum PricingModel {
  /// Default pricing model when the pricing model is unknown or not reported.
  free,
  /// The service plan is based on a subscription model.
  subscription,
  /// The service plan is based on a consumption model.
  consumption,
  /// The service plan allows bringing your own license.
  byol, // bring your own license
}

PricingModel toPricingModel(string value) {
  mixin(EnumSwitch("PricingModel", "free"));
}

PricingModel[] toPricingModels(string[] values) {
  return values.map!toPricingModel.array;
}

string toString(PricingModel value) {
  return value.to!string;
}

string[] toStrings(PricingModel[] values) {
  return values.map!toString.array;
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

  assert(["free", "subscription"].toPricingModels == [
      PricingModel.free, PricingModel.subscription
    ]);
  assert([PricingModel.free, PricingModel.subscription].toStrings == [
      "free", "subscription"
    ]);
}

/// Status of a quota definition.
enum QuotaStatus {
  active, // Default status when the quota status is unknown or not reported.
  deprecated_, // The quota is deprecated and may be removed in the future.
  deleted, // The quota is deleted and no longer available.
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

QuotaStatus[] toQuotaStatuses(string[] values) {
  return values.map!(v => v.toQuotaStatus).array;
}

string toString(QuotaStatus value) {
  return value.to!string;
}

string[] toStrings(QuotaStatus[] values) {
  return values.map!toString.array;
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

  assert(["active", "deprecated"].toQuotaStatuses == [
      QuotaStatus.active, QuotaStatus.deprecated_
    ]);
  assert([QuotaStatus.active, QuotaStatus.deprecated_].toStrings == [
      "active", "deprecated_"
    ]);
}

/// Status of an environment instance.
enum EnvironmentStatus {
  /// Default status when the environment status is unknown or not reported.
  creating,
  /// The environment is active and operational.
  active,
  /// The environment is being updated.
  updating,
  /// The environment is being deleted.
  deleting,
  /// The environment has encountered an error and is not operational.
  error,
  /// The environment is suspended and not operational.
  suspended,
}

EnvironmentStatus toEnvironmentStatus(string value) {
  mixin(EnumSwitch("EnvironmentStatus", "creating"));
}
/// Status of a subscription.
enum SubscriptionStatus {
  /// Default status when the subscription status is unknown or not reported.
  subscribed,
  /// The subscription is in the process of being created.
  subscribing,
  /// The subscription is in the process of being canceled.
  unsubscribing,
  /// The subscription has been canceled.
  unsubscribed,
  /// The subscription has encountered an error.
  error,
  /// The subscription is suspended and not operational.
  suspended,
}

SubscriptionStatus toSubscriptionStatus(string value) {
  mixin(EnumSwitch("SubscriptionStatus", "subscribed"));
}

SubscriptionStatus[] toSubscriptionStatuses(string[] values) {
  return values.map!toSubscriptionStatus.array;
}

string toString(SubscriptionStatus value) {
  return value.to!string;
}

string[] toStrings(SubscriptionStatus[] values) {
  return values.map!toString.array;
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
  assert([SubscriptionStatus.subscribed, SubscriptionStatus.subscribing].toStrings == [
      "subscribed", "subscribing"
    ]);
}

/// Status of a service instance.
enum ServiceInstanceStatus {
  creating, // Default status when the service instance status is unknown or not reported.
  ready, // The service instance is ready and operational.
  failed, // The service instance has encountered an error and is not operational.
  deleting, // The service instance is being deleted.
  updating, // The service instance is being updated.
}

ServiceInstanceStatus toServiceInstanceStatus(string value) {
  mixin(EnumSwitch("ServiceInstanceStatus", "creating"));
}

ServiceInstanceStatus[] toServiceInstanceStatuses(string[] values) {
  return values.map!(v => v.toServiceInstanceStatus).array;
}

string toString(ServiceInstanceStatus value) {
  return value.to!string;
}

string[] toStrings(ServiceInstanceStatus[] values) {
  return values.map!toString.array;
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
  assert([ServiceInstanceStatus.creating, ServiceInstanceStatus.ready].toStrings == [
      "creating", "ready"
    ]);
}

/// Type of environment.
enum EnvironmentType {
  /// Default type when the environment type is unknown or not reported.
  cloudFoundry,
  /// The environment is based on Kyma.
  kyma,
  /// The environment is based on ABAP.
  abap,
  /// The environment is based on NEO.
  neo,
}

EnvironmentType toEnvironmentType(string value) {
  mixin(EnumSwitch("EnvironmentType", "cloudFoundry"));
}

EnvironmentType[] toEnvironmentTypes(string[] values) {
  return values.map!(v => v.toEnvironmentType).array;
}

string toString(EnvironmentType value) {
  return value.to!string;
}

string[] toStrings(EnvironmentType[] values) {
  return values.map!toString.array;
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

  assert(["cloudFoundry", "kyma"].toEnvironmentTypes == [
      EnvironmentType.cloudFoundry, EnvironmentType.kyma
    ]);
  assert([EnvironmentType.cloudFoundry, EnvironmentType.kyma].toStrings == [
      "cloudFoundry", "kyma"
    ]);
}

/// Category of a platform event.
enum EnvironmentEventCategory {
  /// The event is related to the lifecycle of a subaccount.
  subaccountLifecycle,
  /// The event is related to changes in entitlements.
  entitlementChange,
  /// The event is related to the lifecycle of an environment.
  environmentLifecycle,
  /// The event is related to the lifecycle of a subscription.
  subscriptionLifecycle,
  /// The event is related to changes in the directory.
  directoryChange,
  /// The event is related to changes in the global account.
  globalAccountChange,
  /// The event is related to changes in quotas.
  quotaChange,
  /// The event is related to security events.
  securityEvent,
}

EnvironmentEventCategory toEnvironmentEventCategory(string value) {
  mixin(EnumSwitch("EnvironmentEventCategory", "subaccountLifecycle"));
}

EnvironmentEventCategory[] toEnvironmentEventCategories(string[] values) {
  return values.map!(v => v.toEnvironmentEventCategory).array;
}

string toString(EnvironmentEventCategory value) {
  return value.to!string;
}

string[] toStrings(EnvironmentEventCategory[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("EnvironmentEventCategory"));

  assert(
    "subaccountLifecycle".toEnvironmentEventCategory == EnvironmentEventCategory
      .subaccountLifecycle);
  assert(
    "entitlementChange".toEnvironmentEventCategory == EnvironmentEventCategory.entitlementChange);
  assert(
    "environmentLifecycle".toEnvironmentEventCategory == EnvironmentEventCategory
      .environmentLifecycle);
  assert("subscriptionLifecycle".toEnvironmentEventCategory == EnvironmentEventCategory
      .subscriptionLifecycle);
  assert("directoryChange".toEnvironmentEventCategory == EnvironmentEventCategory.directoryChange);
  assert(
    "globalAccountChange".toEnvironmentEventCategory == EnvironmentEventCategory
      .globalAccountChange);
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

  assert(["subaccountLifecycle", "entitlementChange"].toEnvironmentEventCategories == [
      EnvironmentEventCategory.subaccountLifecycle,
      EnvironmentEventCategory.entitlementChange
    ]);
  assert([
    EnvironmentEventCategory.subaccountLifecycle,
    EnvironmentEventCategory.entitlementChange
  ].toStrings == [
    "subaccountLifecycle", "entitlementChange"
  ]);
}

/// Severity of a platform event.
enum EnvironmentEventSeverity {
  /// The event is informational and does not indicate any issues.
  info,
  /// The event indicates a warning that may require attention.
  warning,
  /// The event indicates an error that needs to be addressed.
  error,
  /// The event indicates a critical issue that requires immediate attention.
  critical,
}

EnvironmentEventSeverity toEnvironmentEventSeverity(string value) {
  mixin(EnumSwitch("EnvironmentEventSeverity", "info"));
}

EnvironmentEventSeverity[] toEnvironmentEventSeverities(string[] values) {
  return values.map!(v => v.toEnvironmentEventSeverity).array;
}

string toString(EnvironmentEventSeverity value) {
  return value.to!string;
}

string[] toStrings(EnvironmentEventSeverity[] values) {
  return values.map!toString.array;
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

  assert(["info", "warning"].toEnvironmentEventSeverities == [
      EnvironmentEventSeverity.info, EnvironmentEventSeverity.warning
    ]);
  assert([EnvironmentEventSeverity.info, EnvironmentEventSeverity.warning].toStrings == [
      "info", "warning"
    ]);
}

/// Type of labeled resource.
enum LabeledResourceType {
  /// The labeled resource is a subaccount.
  subaccount,
  /// The labeled resource is a global account.
  globalAccount,
  /// The labeled resource is a directory.
  directory,
  /// The labeled resource is an environment.
  environment,
  /// The labeled resource is a subscription.
  subscription
}

LabeledResourceType toLabeledResourceType(string value) {
  mixin(EnumSwitch("LabeledResourceType", "subaccount"));
}

LabeledResourceType[] toLabeledResourceTypes(string[] values) {
  return values.map!(v => v.toLabeledResourceType).array;
}

string toString(LabeledResourceType value) {
  return value.to!string;
}

string[] toStrings(LabeledResourceType[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("LabeledResourceType"));

  assert("subaccount".toLabeledResourceType == LabeledResourceType.subaccount);
  assert("globalAccount".toLabeledResourceType == LabeledResourceType.globalAccount);
  assert("directory".toLabeledResourceType == LabeledResourceType.directory);
  assert("environment".toLabeledResourceType == LabeledResourceType.environment);
  assert("subscription".toLabeledResourceType == LabeledResourceType.subscription);
  assert("unknown".toLabeledResourceType == LabeledResourceType.subaccount); //

  assert(LabeledResourceType.subaccount.toString == "subaccount");
  assert(LabeledResourceType.globalAccount.toString == "globalAccount");
  assert(LabeledResourceType.directory.toString == "directory");
  assert(LabeledResourceType.environment.toString == "environment");
  assert(LabeledResourceType.subscription.toString == "subscription");

  assert(["subaccount", "globalAccount"].toLabeledResourceTypes == [
      LabeledResourceType.subaccount, LabeledResourceType.globalAccount
    ]);
  assert([LabeledResourceType.subaccount, LabeledResourceType.globalAccount].toStrings == [
      "subaccount", "globalAccount"
    ]);
}
