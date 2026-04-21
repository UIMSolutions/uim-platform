module uim.platform.situation_automation.domain.types;

// ID aliases
struct SituationTemplateId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct SituationInstanceId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct SituationActionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct AutomationRuleId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct EntityTypeId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct DataContextId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct NotificationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct DashboardId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}


// --- Situation Template ---

enum SituationSeverity {
    low,
    medium,
    high,
    critical,
}

enum SituationCategory {
    financial,
    logistics,
    procurement,
    production,
    sales,
    humanResources,
    maintenance,
    quality,
    compliance,
    custom,
}

enum TemplateStatus {
    draft,
    active,
    inactive,
    deprecated_,
}

// --- Situation Instance ---

enum InstanceStatus {
    open,
    inProgress,
    resolved,
    dismissed,
    escalated,
    expired,
    error,
}

enum ResolutionType {
    manual,
    automatic,
    escalated,
    expired,
    dismissed,
}

// --- Situation Action ---

enum ActionType {
    apiCall,
    notification,
    workflowTrigger,
    dataUpdate,
    approval,
    email,
    webhook,
    script,
    custom,
}

enum ActionStatus {
    draft,
    active,
    inactive,
    error,
}

enum HttpMethod {
    get_,
    post_,
    put_,
    patch_,
    delete_,
}

// --- Automation Rule ---

enum RuleStatus {
    active,
    inactive,
    draft,
    error,
}

enum ConditionOperator {
    equals,
    notEquals,
    greaterThan,
    lessThan,
    greaterOrEqual,
    lessOrEqual,
    contains,
    startsWith,
    endsWith,
    in_,
    notIn,
    between,
    isNull,
    isNotNull,
    matches,
}

enum LogicalOperator {
    and_,
    or_,
    not_,
}

enum RulePriority {
    low,
    medium,
    high,
    critical,
}

// --- Entity Type ---

enum EntityCategory {
    masterData,
    transactional,
    organizational,
    configuration,
    custom,
}

// --- Notification ---

enum NotificationStatus {
    pending,
    sent,
    read_,
    acknowledged,
    failed,
}

enum NotificationChannel {
    inApp,
    email,
    sms,
    webhook,
    push,
}

enum NotificationPriority {
    low,
    medium,
    high,
    urgent,
}

// --- Dashboard ---

enum DashboardType {
    situationOverview,
    automationPerformance,
    resolutionAnalytics,
    entityAnalysis,
    timeSaved,
    trendAnalysis,
    custom,
}

enum MetricType {
    count,
    average,
    sum,
    percentage,
    duration,
    rate,
    trend,
}

enum TimeRange {
    last24Hours,
    last7Days,
    last30Days,
    last90Days,
    lastYear,
    custom,
}
