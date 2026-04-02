module domain.types;

/// Unique identifier type aliases for type safety.
alias GlobalAccountId = string;
alias DirectoryId = string;
alias SubaccountId = string;
alias EntitlementId = string;
alias EnvironmentInstanceId = string;
alias SubscriptionId = string;
alias ServicePlanId = string;
alias PlatformEventId = string;
alias LabelId = string;
alias TenantId = string;

/// Status of a global account.
enum GlobalAccountStatus
{
    active,
    suspended,
    terminated,
    migrating,
}

/// License type for a global account.
enum LicenseType
{
    enterprise,
    trial,
    partner,
    internal,
}

/// Status of a directory entity.
enum DirectoryStatus
{
    active,
    inactive,
    deleting,
}

/// Features enabled on a directory.
enum DirectoryFeature
{
    default_,
    entitlements,
    authorizations,
}

/// Status of a subaccount.
enum SubaccountStatus
{
    active,
    suspended,
    creating,
    updating,
    deleting,
    moveInProgress,
    moveFailed,
}

/// Usage type of a subaccount.
enum SubaccountUsage
{
    unset,
    production,
    development,
    test,
    staging,
    demo,
}

/// Status of an entitlement assignment.
enum EntitlementStatus
{
    active,
    pending,
    revoked,
    expired,
}

/// Category of a service plan.
enum ServicePlanCategory
{
    service,
    application,
    environment,
    elasticService,
}

/// Pricing model for a service plan.
enum PricingModel
{
    free,
    subscription,
    consumption,
    byol,       // bring your own license
}

/// Status of an environment instance.
enum EnvironmentStatus
{
    creating,
    active,
    updating,
    deleting,
    error,
    suspended,
}

/// Type of environment.
enum EnvironmentType
{
    cloudFoundry,
    kyma,
    abap,
    neo,
}

/// Status of a SaaS subscription.
enum SubscriptionStatus
{
    subscribed,
    subscribing,
    unsubscribing,
    unsubscribed,
    error,
    suspended,
}

/// Category of a platform event.
enum PlatformEventCategory
{
    subaccountLifecycle,
    entitlementChange,
    environmentLifecycle,
    subscriptionLifecycle,
    directoryChange,
    globalAccountChange,
    quotaChange,
    securityEvent,
}

/// Severity of a platform event.
enum PlatformEventSeverity
{
    info,
    warning,
    error,
    critical,
}

/// Type of labeled resource.
enum LabeledResourceType
{
    globalAccount,
    directory,
    subaccount,
    environmentInstance,
    subscription,
}
