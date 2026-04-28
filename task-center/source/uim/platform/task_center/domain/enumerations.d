module uim.platform.task_center.domain.enumerations;

enum TaskStatus {
    open,
    inProgress,
    completed,
    cancelled,
    failed,
    forwarded,
    reserved
}

enum TaskPriority {
    low,
    medium,
    high,
    veryHigh
}

enum TaskCategory {
    approval,
    review,
    toDoItem,
    notification,
    action,
    workflow,
    informational
}

enum ProviderType {
    s4hana,
    successFactors,
    ariba,
    fieldglass,
    concur,
    sapBuild,
    custom
}

enum ProviderStatus {
    active,
    inactive,
    error,
    syncing
}

enum AuthenticationType {
    oauth2,
    basicAuth,
    certificate,
    apiKey,
    saml
}

enum ActionType {
    approve,
    reject,
    forward,
    claim,
    release,
    escalate,
    complete,
    cancel,
    resubmit
}

enum SubstitutionStatus {
    active,
    inactive,
    expired,
    pending
}

enum AttachmentStatus {
    uploaded,
    processing,
    available,
    deleted
}

enum FilterCriterionType {
    status,
    priority,
    provider,
    category,
    dueDate,
    assignee,
    creator,
    taskDefinition
}
