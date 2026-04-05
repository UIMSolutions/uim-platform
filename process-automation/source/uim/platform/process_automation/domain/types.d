/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.types;

// ID aliases
alias ProcessId = string;
alias ProcessInstanceId = string;
alias TaskId = string;
alias DecisionId = string;
alias FormId = string;
alias AutomationId = string;
alias TriggerId = string;
alias ActionId = string;
alias VisibilityId = string;
alias ArtifactId = string;
alias TenantId = string;
alias UserId = string;
alias ProjectId = string;
alias VersionId = string;

// --- Process (Workflow Definition) ---

enum ProcessStatus {
    draft,
    active,
    inactive,
    deprecated_,
    error,
}

enum ProcessCategory {
    workflow,
    approval,
    notification,
    automation,
    hybrid,
}

enum StepType {
    startEvent,
    endEvent,
    userTask,
    serviceTask,
    scriptTask,
    decisionTask,
    automationTask,
    mailTask,
    parallelGateway,
    exclusiveGateway,
    inclusiveGateway,
    eventBasedGateway,
    subProcess,
    callActivity,
    timerEvent,
    messageEvent,
    signalEvent,
    errorEvent,
    condition,
}

// --- Process Instance ---

enum InstanceStatus {
    running,
    completed,
    failed,
    suspended,
    cancelled,
    waiting,
    error,
}

enum InstancePriority {
    low,
    medium,
    high,
    critical,
}

// --- Task ---

enum TaskStatus {
    ready,
    reserved,
    inProgress,
    completed,
    failed,
    cancelled,
    forwarded,
}

enum TaskPriority {
    low,
    medium,
    high,
    veryHigh,
}

enum TaskType {
    approval,
    review,
    form,
    decision,
    notification,
    custom,
}

// --- Decision (Business Rules) ---

enum DecisionStatus {
    draft,
    active,
    inactive,
    deprecated_,
}

enum DecisionType {
    decisionTable,
    textRule,
    expression,
    decisionTree,
}

enum HitPolicy {
    first,
    any,
    priority,
    unique,
    collect,
    ruleOrder,
    outputOrder,
}

enum ConditionType {
    equals,
    notEquals,
    greaterThan,
    lessThan,
    greaterOrEqual,
    lessOrEqual,
    between,
    contains,
    startsWith,
    endsWith,
    in_,
    notIn,
}

// --- Form ---

enum FormStatus {
    draft,
    published,
    inactive,
    deprecated_,
}

enum FieldType {
    text,
    number,
    date,
    datetime,
    boolean_,
    dropdown,
    radio,
    checkbox,
    textarea,
    fileUpload,
    table,
    paragraph,
    headline,
    link,
    image,
}

// --- Automation (RPA Bot) ---

enum AutomationStatus {
    draft,
    active,
    inactive,
    error,
}

enum AutomationType {
    attended,
    unattended,
    hybrid,
    api,
}

enum AutomationRunStatus {
    queued,
    running,
    completed,
    failed,
    cancelled,
    timedOut,
}

// --- Trigger ---

enum TriggerType {
    manual,
    scheduled,
    api,
    event,
    email,
    webhook,
    formSubmission,
}

enum TriggerStatus {
    active,
    inactive,
    error,
}

enum ScheduleFrequency {
    once,
    minutely,
    hourly,
    daily,
    weekly,
    monthly,
    yearly,
    cron,
}

// --- Action (Integration) ---

enum ActionStatus {
    draft,
    active,
    inactive,
    error,
}

enum ActionType {
    restApi,
    odata,
    rfc,
    soap,
    graphql,
    custom,
}

enum HttpMethod {
    get_,
    post_,
    put_,
    patch_,
    delete_,
    head_,
    options_,
}

// --- Visibility (Process Monitoring) ---

enum VisibilityStatus {
    active,
    inactive,
    error,
}

enum DashboardType {
    processOverview,
    instanceDetail,
    taskAnalytics,
    performanceKpi,
    bottleneckAnalysis,
    slaCompliance,
    custom,
}

enum MetricType {
    count,
    average,
    sum,
    min_,
    max_,
    percentage,
    duration,
}

// --- Artifact Store ---

enum ArtifactType {
    processTemplate,
    botTemplate,
    formTemplate,
    decisionTemplate,
    actionTemplate,
    connector,
    plugin,
}

enum ArtifactStatus {
    available,
    installed,
    updateAvailable,
    deprecated_,
}
