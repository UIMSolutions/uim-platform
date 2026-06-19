/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.enumerations;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:

// --- Process (Workflow Definition) ---

enum ProcessStatus {
    // Draft: being designed, not yet active
    draft,
    // Active: published and can be instantiated
    active,
    // Inactive: temporarily disabled, cannot be instantiated
    inactive,
    // Deprecated: should not be used for new instances, but existing ones can continue
    deprecated_,
    // Error: has issues that need to be resolved
    error,
    // Archived: no longer active, kept for historical reference
    archived,
    // Unknown: status is not recognized
    unknown,
    // Deleted: removed from the system (soft delete)
    deleted,
    // Suspended: temporarily paused, can be resumed
    suspended,
    // Completed: process has finished successfully
    completed,
    // Failed: process has finished with errors
    failed,
    // Cancelled: process was cancelled before completion
    cancelled,
    // Waiting: process is waiting for an external event or trigger
    waiting,
    // Terminated: process was forcefully stopped
    terminated,
    // Resumed: process was resumed after being suspended
    resumed,
    // RollingBack: process is rolling back after a failure
    rollingBack,
    // RolledBack: process has completed rolling back
    rolledBack,
    // Migrating: process is being migrated to a new version
    migrating,
    // Migrated: process has been migrated to a new version
    migrated,
    // Versioning: process is being versioned
    versioning,
    // Versioned: process has been versioned
    versioned,
    // Cloning: process is being cloned
    cloning,
    // Cloned: process has been cloned
    cloned,
    // Testing: process is being tested
    testing,
    // Tested: process has been tested
    tested,
    // Validating: process is being validated
    validating,
    // Validated: process has been validated
    validated,
    // Releasing: process is being released to production
    releasing,
    // Released: process has been released to production
    released,
}

ProcessStatus toProcessStatus(string status) {
    switch (status.toLower) {
    case "draft":
        return ProcessStatus.draft;
    case "active":
        return ProcessStatus.active;
    case "inactive":
        return ProcessStatus.inactive;
    case "deprecated":
        return ProcessStatus.deprecated_;
    case "error":
        return ProcessStatus.error;
    case "archived":
        return ProcessStatus.archived;
    case "unknown":
        return ProcessStatus.unknown;
    case "deleted":
        return ProcessStatus.deleted;
    case "suspended":
        return ProcessStatus.suspended;
    case "completed":
        return ProcessStatus.completed;
    case "failed":
        return ProcessStatus.failed;
    case "cancelled":
        return ProcessStatus.cancelled;
    case "waiting":
        return ProcessStatus.waiting;
    case "terminated":
        return ProcessStatus.terminated;
    case "resumed":
        return ProcessStatus.resumed;
    case "rollingback":
        return ProcessStatus.rollingBack;
    case "rolledback":
        return ProcessStatus.rolledBack;
    case "migrating":
        return ProcessStatus.migrating;
    case "migrated":
        return ProcessStatus.migrated;
    case "versioning":
        return ProcessStatus.versioning;
    case "versioned":
        return ProcessStatus.versioned;
    case "cloning":
        return ProcessStatus.cloning;
    case "cloned":
        return ProcessStatus.cloned;
    case "testing":
        return ProcessStatus.testing;
    case "tested":
        return ProcessStatus.tested;
    case "validating":
        return ProcessStatus.validating;
    case "validated":
        return ProcessStatus.validated;
    case "releasing":
        return ProcessStatus.releasing;
    case "released":
        return ProcessStatus.released;
    default:
        return ProcessStatus.unknown;
    }
}
/// 
unittest {
    assert(toProcessStatus("active") == ProcessStatus.active);
    assert(toProcessStatus("inactive") == ProcessStatus.inactive);
    assert(toProcessStatus("deprecated") == ProcessStatus.deprecated_);
    assert(toProcessStatus("error") == ProcessStatus.error);
    assert(toProcessStatus("archived") == ProcessStatus.archived);
    assert(toProcessStatus("unknown") == ProcessStatus.unknown);
    assert(toProcessStatus("deleted") == ProcessStatus.deleted);
    assert(toProcessStatus("suspended") == ProcessStatus.suspended);
    assert(toProcessStatus("completed") == ProcessStatus.completed);
    assert(toProcessStatus("failed") == ProcessStatus.failed);
    assert(toProcessStatus("cancelled") == ProcessStatus.cancelled);
    assert(toProcessStatus("waiting") == ProcessStatus.waiting);
    assert(toProcessStatus("terminated") == ProcessStatus.terminated);
    assert(toProcessStatus("resumed") == ProcessStatus.resumed);
    assert(toProcessStatus("rollingback") == ProcessStatus.rollingBack);
    assert(toProcessStatus("rolledback") == ProcessStatus.rolledBack);
    assert(toProcessStatus("migrating") == ProcessStatus.migrating);
    assert(toProcessStatus("migrated") == ProcessStatus.migrated);
    assert(toProcessStatus("versioning") == ProcessStatus.versioning);
    assert(toProcessStatus("versioned") == ProcessStatus.versioned);
    assert(toProcessStatus("cloning") == ProcessStatus.cloning);
    assert(toProcessStatus("cloned") == ProcessStatus.cloned);
    assert(toProcessStatus("testing") == ProcessStatus.testing);
    assert(toProcessStatus("tested") == ProcessStatus.tested);
    assert(toProcessStatus("validating") == ProcessStatus.validating);
    assert(toProcessStatus("validated") == ProcessStatus.validated);
    assert(toProcessStatus("releasing") == ProcessStatus.releasing);
    assert(toProcessStatus("released") == ProcessStatus.released);
    // TODO: assert(toProcessStatus("invalid") == ProcessStatus.draft);
}

enum ProcessCategory {
    // Used for processes that represent a sequence of tasks or activities that achieve a specific business outcome, which may involve multiple steps, decision points, and interactions between different roles or systems
    workflow,
    // Used for processes that represent a specific type of workflow that requires approval from one or more stakeholders, which may involve routing, escalation, and tracking of approval requests and responses
    approval,
    // Used for processes that represent a specific type of workflow that involves sending notifications or alerts to users or systems based on certain events or conditions, which may involve different channels such as email, SMS, or in-app notifications
    notification,
    // Used for processes that represent a specific type of workflow that involves automating repetitive tasks or activities using robotic process automation (RPA) or other automation technologies, which may involve integration with various systems and applications to perform tasks such as data entry, data extraction, or system interactions
    automation,
    // Used for processes that represent a combination of different types of workflows, such as a workflow that includes both approval and automation steps, which may require coordination and orchestration of different activities and interactions to achieve the desired outcome   
    hybrid,
    // Used for processes that do not fit into any of the above categories, which may represent unique or specialized workflows that require custom handling and processing based on specific business requirements or use cases
    custom,
}

ProcessCategory toProcessCategory(string category) {
    switch (category.toLower) {
        static foreach (member; __traits(allMembers, ProcessCategory)) {
    case member:
            return __traits(getMember, ProcessCategory, member);
        }
    default:
        return ProcessCategory.workflow;
    }

}
///
unittest {
    assert(toProcessCategory("workflow") == ProcessCategory.workflow);
    assert(toProcessCategory("approval") == ProcessCategory.approval);
    assert(toProcessCategory("notification") == ProcessCategory.notification);
    assert(toProcessCategory("automation") == ProcessCategory.automation);
    assert(toProcessCategory("hybrid") == ProcessCategory.hybrid);
    assert(toProcessCategory("custom") == ProcessCategory.custom);
}

enum StepType {
    // Used for the starting point of a process, which may trigger the execution of subsequent steps based on certain conditions or events  
    startEvent,
    // Used for the ending point of a process, which may indicate the completion of the process and may trigger certain actions or notifications based on the outcome of the process execution  
    endEvent,
    // Used for steps that require user interaction or input, which may involve tasks such as filling out forms, providing approvals, or making decisions based on the process flow and requirements
    userTask,
    // Used for steps that involve automated processing or system interactions, which may include tasks such as calling APIs, executing scripts, or performing data transformations based on the process logic and integration requirements
    serviceTask,
    // Used for steps that involve executing custom scripts or code snippets, which may allow for more complex processing and logic implementation based on specific business requirements or use cases
    scriptTask,
    // Used for steps that involve making decisions based on certain conditions or rules, which may include tasks such as evaluating expressions, applying business rules, or determining the flow of the process based on the outcomes of the decision logic
    decisionTask,
    // Used for steps that involve executing automated tasks or activities using robotic process automation (RPA) or other automation technologies, which may include tasks such as data entry, data extraction, or system interactions based on the process requirements and integration needs
    automationTask,
    // Used for steps that involve sending email notifications to users or systems based on certain events or conditions, which may include tasks such as composing email content, determining recipients, and configuring email delivery settings based on the process requirements and notification needs
    mailTask,
    // Used for steps that represent a branching point in the process flow where multiple paths can be executed in parallel, which may allow for concurrent processing of different activities or tasks based on the process logic and requirements
    parallelGateway,
    // Used for steps that represent a branching point in the process flow where only one path can be executed based on certain conditions or events, which may allow for exclusive processing of different activities or tasks based on the process logic and requirements
    exclusiveGateway,
    // Used for steps that represent a branching point in the process flow where one or more paths can be executed based on certain conditions or events, which may allow for inclusive processing of different activities or tasks based on the process logic and requirements
    inclusiveGateway,
    // Used for steps that represent a branching point in the process flow where the path taken is determined by events that occur during process execution, which may allow for event-driven processing of different activities or tasks based on the process logic and requirements
    eventBasedGateway,
    //  Used for steps that represent a subprocess within the main process, which may allow for modularization and reuse of process logic and activities based on specific business requirements or use cases
    subProcess,
    // Used for steps that represent a call to another process, which may allow for orchestration and coordination of different processes based on specific business requirements or use cases
    callActivity,
    // Used for steps that represent a timer event, which may allow for time-based processing of different activities or tasks based on the process logic and requirements, such as triggering certain actions after a specified duration or at a specific time
    timerEvent,
    // Used for steps that represent a message event, which may allow for message-based processing of different activities or tasks based on the process logic and requirements, such as triggering certain actions upon receiving specific messages or events during process execution
    messageEvent,
    // Used for steps that represent a signal event, which may allow for signal-based processing of different activities or tasks based on the process logic and requirements, such as triggering certain actions upon receiving specific signals or events during process execution
    signalEvent,
    // Used for steps that represent an error event, which may allow for error handling and exception processing of different activities or tasks based on the process logic and requirements, such as triggering certain actions upon encountering specific errors or exceptions during process execution
    errorEvent,
    // Used for steps that represent a condition or expression evaluation, which may allow for conditional processing of different activities or tasks based on the process logic and requirements, such as determining the flow of the process based on the outcomes of the condition evaluation
    condition,
    // Used for steps that represent a custom or specialized activity that does not fit into any of the above types, which may require custom handling and processing based on specific business requirements or use cases
    custom,
}

StepType toStepType(string type) {
    switch (type.toLower) {
    case "start_event":
        return StepType.startEvent;
    case "end_event":
        return StepType.endEvent;
    case "user_task":
        return StepType.userTask;
    case "service_task":
        return StepType.serviceTask;
    case "script_task":
        return StepType.scriptTask;
    case "decision_task":
        return StepType.decisionTask;
    case "automation_task":
        return StepType.automationTask;
    case "mail_task":
        return StepType.mailTask;
    case "parallel_gateway":
        return StepType.parallelGateway;
    case "exclusive_gateway":
        return StepType.exclusiveGateway;
    case "inclusive_gateway":
        return StepType.inclusiveGateway;
    case "event_based_gateway":
        return StepType.eventBasedGateway;
    case "sub_process":
        return StepType.subProcess;
    case "call_activity":
        return StepType.callActivity;
    case "timer_event":
        return StepType.timerEvent;
    case "message_event":
        return StepType.messageEvent;
    case "signal_event":
        return StepType.signalEvent;
    case "error_event":
        return StepType.errorEvent;
    case "condition":
        return StepType.condition;
    case "custom":
        return StepType.custom;
    default:
        return StepType.userTask;
    }
}

// --- Process Instance ---
enum InstanceStatus {
    // Used for instances that are currently running and have not yet completed, which may require monitoring and management to ensure successful execution and timely completion
    running,
    // Used for instances that have completed successfully, which may indicate that the process has achieved its intended outcome and may require review or archiving before they can be reactivated or used again
    completed,
    // Used for instances that have completed with errors, which may indicate that the process has encountered issues during execution and may require troubleshooting and resolution before they can be reactivated or used again
    failed,
    // Used for instances that have been suspended, which may indicate that they are temporarily paused and may require resolution of underlying issues or conditions before they can be resumed and continue execution
    suspended,
    // Used for instances that have been cancelled, which may indicate that they were intentionally stopped before completion and may require review or archiving before they can be reactivated or used again
    cancelled,
    // Used for instances that are waiting for an external event or trigger to continue execution, which may indicate that they are temporarily paused and may require monitoring and management to ensure timely response to the event or trigger
    waiting,
    // Used for instances that were forcefully stopped, which may indicate that they were terminated due to critical issues or conditions and may require review and resolution before they can be reactivated or used again
    error,
    // Used for instances that have an unknown status, which may indicate that their current state cannot be determined or is not recognized, and may require investigation and resolution to determine the appropriate status and next steps
    unknown,
}

InstanceStatus toInstanceStatus(string status) {
    switch (status.toLower) {
        static foreach (member; __traits(allMembers, InstanceStatus)) {
    case member:
            return __traits(getMember, InstanceStatus, member);
        }
    default:
        return InstanceStatus.unknown;
    }
}

enum InstancePriority {
    // Used for instances that have a low priority level, which may indicate that they are less critical and can be processed with lower urgency compared to higher priority instances  
    low,
    // Used for instances that have a medium priority level, which may indicate that they are of moderate importance and should be processed in a timely manner, but may not require immediate attention compared to high priority instances
    medium,
    // Used for instances that have a high priority level, which may indicate that they are critical and require prompt attention and processing to ensure successful execution and timely completion
    high,
    // Used for instances that have a critical priority level, which may indicate that they are of utmost importance and require immediate attention and processing to prevent severe consequences or ensure successful execution and timely completion
    critical,
}

InstancePriority toInstancePriority(string priority) {
    switch (priority.toLower) {
        static foreach (member; __traits(allMembers, InstancePriority)) {
    case member:
            return __traits(getMember, InstancePriority, member);
        }
    default:
        return InstancePriority.medium;
    }
}

// --- Event (for Alerting and Monitoring) ---
enum EventCategory : string {
    // Used for events that represent notifications about the status or progress of a process instance, which may include information such as instance ID, current step, and any relevant data or context to keep users informed about the execution of the process
    notification = "NOTIFICATION",
    // Used for events that represent alerts about critical issues or conditions that require immediate attention and action, which may include information such as instance ID, error details, and recommended actions to help users quickly identify and resolve the underlying issues
    alert = "ALERT",
    // Used for events that represent exceptions or errors that occur during the execution of a process instance, which may include information such as instance ID, error details, and stack traces to help users diagnose and troubleshoot the issues effectively
    exception_ = "EXCEPTION",
    // Used for events that represent custom or specialized categories that do not fit into any of the above categories, which may require custom handling and processing based on specific business requirements or use cases
    custom = "CUSTOM"
}

EventCategory toEventCategory(string category) {
    switch (category.toUpper) {
        case "NOTIFICATION":
            return EventCategory.notification;
        case "ALERT":
            return EventCategory.alert;
        case "EXCEPTION":
            return EventCategory.exception_;
        case "CUSTOM":
            return EventCategory.custom;
        default:
            return EventCategory.notification;
    }
}

// --- PATask ---

enum TaskStatus {
    // Used for tasks that are ready to be worked on, which may indicate that they have been assigned and are
    ready,
    // Used for tasks that have been reserved by a user but work has not yet started, which may indicate that they are in the process of being claimed and may require follow-up to ensure timely completion
    reserved,
    // Used for tasks that are currently being worked on, which may indicate that they are in progress and may require monitoring and management to ensure successful completion and timely resolution of any issues that may arise during task execution
    inProgress,
    // Used for tasks that have been completed successfully, which may indicate that they have fulfilled their intended purpose and may require review or archiving before they can be reactivated or used again
    completed,
    // Used for tasks that have encountered errors during execution, which may indicate that they have not fulfilled their intended purpose and may require troubleshooting and resolution before they can be reactivated or used again
    failed,
    // Used for tasks that have been cancelled, which may indicate that they were intentionally stopped before completion and may require review or archiving before they can be reactivated or used again
    cancelled,
    // Used for tasks that have been forwarded to another user or group, which may indicate that they are in the process of being reassigned and may require follow-up to ensure timely completion by the new assignee 
    forwarded,
    // Used for tasks that have an unknown status, which may indicate that their current state cannot be determined or is not recognized, and may require investigation and resolution to determine the appropriate status and next steps
    unknown,
}

TaskStatus toTaskStatus(string status) {
    switch (status.toLower) {
        case "ready":
            return TaskStatus.ready;
        case "reserved":
            return TaskStatus.reserved;
        case "in_progress":
            return TaskStatus.inProgress;
        case "completed":
            return TaskStatus.completed;
        case "failed":
            return TaskStatus.failed;
        case "cancelled":
            return TaskStatus.cancelled;
        case "forwarded":
            return TaskStatus.forwarded;
        case "unknown":
            return TaskStatus.unknown;
        default:
            return TaskStatus.ready;
    }
}

enum TaskPriority {
    // Used for tasks that have a low priority level, which may indicate that they are less critical and can be processed with lower urgency compared to higher priority tasks
    low,
    // Used for tasks that have a medium priority level, which may indicate that they are of moderate importance and should be processed in a timely manner, but may not require immediate attention compared to high priority tasks
    medium,
    // Used for tasks that have a high priority level, which may indicate that they are critical and require prompt attention and processing to ensure successful completion and timely resolution of any issues that may arise during task execution
    high,
    // Used for tasks that have a very high priority level, which may indicate that they are of utmost importance and require immediate attention and processing to prevent severe consequences or ensure successful completion and timely resolution of any issues that may arise during task execution
    veryHigh,
    // Used for tasks that have an unknown priority level, which may indicate that their priority cannot be determined or is not recognized, and may require investigation and resolution to determine the appropriate priority and next steps
    unknown,
}

TaskPriority toTaskPriority(string priority) {
    switch(priority.toLower) {
        case "low":
            return TaskPriority.low;
        case "medium":
            return TaskPriority.medium;
        case "high":
            return TaskPriority.high;
        case "very_high", "veryhigh":
            return TaskPriority.veryHigh;
        case "unknown":
            return TaskPriority.unknown;
        default:
            return TaskPriority.medium;
    }   
}
/// 
unittest {
    assert(toTaskPriority("low") == TaskPriority.low);
    assert(toTaskPriority("medium") == TaskPriority.medium);
    assert(toTaskPriority("high") == TaskPriority.high);
    assert(toTaskPriority("veryhigh") == TaskPriority.veryHigh);
    assert(toTaskPriority("unknown") == TaskPriority.unknown);

    assert(toTaskPriority("default") == TaskPriority.medium);

    assert(TaskPriority.low.to!string == "low");
    assert(TaskPriority.medium.to!string == "medium");
    assert(TaskPriority.high.to!string == "high");
    assert(TaskPriority.veryHigh.to!string == "veryHigh");
    assert(TaskPriority.unknown.to!string == "unknown");
}


enum TaskType {
    // Used for tasks that require approval from one or more stakeholders, which may involve routing, escalation, and tracking of approval requests and responses based on the process flow and requirements
    approval,
    // Used for tasks that require review or feedback from users or systems, which may involve providing comments, suggestions, or ratings based on the process flow and requirements
    review,
    // Used for tasks that require users to fill out forms or provide input, which may involve designing and configuring forms based on the process flow and requirements
    form,
    // Used for tasks that require making decisions based on certain conditions or rules, which may involve evaluating expressions, applying business rules, or determining the flow of the process based on the outcomes of the decision logic
    decision,
    // Used for tasks that involve sending notifications or alerts to users or systems based on certain events or conditions, which may involve different channels such as email, SMS, or in-app notifications based on the process flow and requirements
    notification,
    // Used for tasks that represent a custom or specialized type that does not fit into any of the above types, which may require custom handling and processing based on specific business requirements or use cases
    custom,
}

TaskType toTaskType(string type) {
    const map = [
        "approval": TaskType.approval,
        "review": TaskType.review,
        "form": TaskType.form,
        "decision": TaskType.decision,
        "notification": TaskType.notification,
        "custom": TaskType.custom
    ];
    return map.get(type.toLower, TaskType.custom);
}
// --- Decision (Business Rules) ---

enum DecisionStatus {
    // Decision has  been created but not yet published, which may indicate that it is still being designed and may require further development and testing before it can be used in production
    draft,
    // Decision has been published and is active, which may indicate that it is ready for use in production and may require monitoring and maintenance to ensure its continued effectiveness and relevance over time
    active,
    // Decision has been temporarily disabled, which may indicate that it is not currently being used in production and may require resolution of underlying issues or conditions before it can be reactivated and used again
    inactive,
    // Decision has been deprecated, which may indicate that it should not be used for new instances, but existing ones can continue to use them, which may require review and archiving before they can be reactivated or used again
    deprecated_,
}

DecisionStatus toDecisionStatus(string status) {
    const map = [
        "draft": DecisionStatus.draft,
        "active": DecisionStatus.active,
        "inactive": DecisionStatus.inactive,
        "deprecated": DecisionStatus.deprecated_
    ];
    return map.get(status.toLower, DecisionStatus.draft);
}

enum DecisionType {
    // Decision that is represented in a tabular format, which may include rows and columns to define conditions, rules, and corresponding outcomes based on the process flow and requirements
    decisionTable,
    // Decision that is represented in a textual format, which may include natural language descriptions of conditions, rules, and corresponding outcomes based on the process flow and requirements
    textRule,
    // Decision that is represented as an expression or formula, which may include mathematical or logical expressions to define conditions, rules, and corresponding outcomes based on the process flow and requirements
    expression,
    // Decision that is represented as a decision tree, which may include a hierarchical structure of nodes and branches to define conditions, rules, and corresponding outcomes based on the process flow and requirements
    decisionTree,
}

DecisionType toDecisionType(string type) {
    const map = [
        "decision_table": DecisionType.decisionTable,
        "text_rule": DecisionType.textRule,
        "expression": DecisionType.expression,
        "decision_tree": DecisionType.decisionTree
    ];
    return map.get(type.toLower, DecisionType.decisionTable);
}

enum HitPolicy {
    // Decision logic that returns the first matching rule, which may indicate that only one rule will be evaluated and returned based on the process flow and requirements
    first,
    // Decision logic that returns any matching rule, which may indicate that multiple rules can be evaluated and returned based on the process flow and requirements
    any,
    // Decision logic that returns the matching rule with the highest priority, which may indicate that rules are evaluated based on their assigned priority and the one with the highest priority is returned based on the process flow and requirements
    priority,
    // Decision logic that returns only unique matching rules, which may indicate that duplicate rules are not allowed and only distinct rules will be evaluated and returned based on the process flow and requirements
    unique,
    // Decision logic that returns all matching rules and collects their outcomes, which may indicate that multiple rules can be evaluated and their outcomes are aggregated based on the process flow and requirements
    collect,
    // Decision logic that returns matching rules in the order they are defined, which may indicate that rules are evaluated and returned based on their sequence in the decision table
    ruleOrder,
    // Decision logic that returns matching rules in the order of their output values, which may indicate that rules are evaluated and returned based on the sequence of their outcomes
    outputOrder,
}

HitPolicy toHitPolicy(string policy) {
    const map = [
        "first": HitPolicy.first,
        "any": HitPolicy.any,
        "priority": HitPolicy.priority,
        "unique": HitPolicy.unique,
        "collect": HitPolicy.collect,
        "rule_order": HitPolicy.ruleOrder,
        "output_order": HitPolicy.outputOrder
    ];
    return map.get(policy.toLower, HitPolicy.first);
}

enum ConditionType {
    // Condition that checks for equality between values, which may indicate that the values must be the same for the condition to be satisfied based on the process flow and requirements
    equals,
    // Condition that checks for inequality between values, which may indicate that the values must be different for the condition to be satisfied based on the process flow and requirements
    notEquals,
    // Condition that checks if a value is greater than another value, which may indicate that the first value must be larger than the second value for the condition to be satisfied based on the process flow and requirements
    greaterThan,
    // Condition that checks if a value is less than another value, which may indicate that the first value must be smaller than the second value for the condition to be satisfied based on the process flow and requirements
    lessThan,
    // Condition that checks if a value is greater than or equal to another value, which may indicate that the first value must be larger than or equal to the second value for the condition to be satisfied based on the process flow and requirements
    greaterOrEqual,
    // Condition that checks if a value is less than or equal to another value, which may indicate that the first value must be smaller than or equal to the second value for the condition to be satisfied based on the process flow and requirements
    lessOrEqual,
    // Condition that checks if a value falls within a specified range between two values, which may indicate that the value must be greater than or equal to the lower bound and less than or equal to the upper bound for the condition to be satisfied based on the process flow and requirements
    between,
    // Condition that checks if a value contains a specified substring, which may indicate that the value must include the substring for the condition to be satisfied based on the process flow and requirements
    contains,
    // Condition that checks if a value starts with a specified substring, which may indicate that the value must begin with the substring for the condition to be satisfied based on the process flow and requirements
    startsWith,
    // Condition that checks if a value ends with a specified substring, which may indicate that the value must end with the substring for the condition to be satisfied based on the process flow and requirements
    endsWith,
    // Condition that checks if a value is within a specified set of values, which may indicate that the value must be one of the specified values for the condition to be satisfied based on the process flow and requirements
    in_,
    // Condition that checks if a value is not within a specified set of values, which may indicate that the value must not be one of the specified values for the condition to be satisfied based on the process flow and requirements
    notIn,
}

ConditionType toConditionType(string s) {
    const map = [
        "equals": ConditionType.equals,
        "not_equals": ConditionType.notEquals,
        "greater_than": ConditionType.greaterThan,
        "less_than": ConditionType.lessThan,
        "greater_or_equal": ConditionType.greaterOrEqual,
        "less_or_equal": ConditionType.lessOrEqual,
        "between": ConditionType.between,
        "contains": ConditionType.contains,
        "starts_with": ConditionType.startsWith,
        "ends_with": ConditionType.endsWith,
        "in": ConditionType.in_,
        "not_in": ConditionType.notIn
    ];
    return map.get(s.toLower, ConditionType.equals);
}
// --- Form ---

enum FormStatus {
    // Form is being designed and is not yet active, which may indicate that it is still being developed and may require further work and testing before it can be used in production
    draft,
    // Form has been published and is active, which may indicate that it is ready for use in production and may require monitoring and maintenance to ensure its continued effectiveness and relevance over time
    published,
    // Form has been temporarily disabled, which may indicate that it is not currently being used in production and may require resolution of underlying issues or conditions before it can be reactivated and used again
    inactive,
    // Form has been deprecated, which may indicate that it should not be used for new instances, but existing ones can continue to use them, which may require review and archiving before they can be reactivated or used again
    deprecated_,
    // Form has been archived, which may indicate that it is no longer active and is kept for historical reference, and may require review before it can be reactivated or used again
    archived,
    // Form has encountered errors, which may indicate that it has issues that need to be resolved before it can be reactivated and used again
    error,
}

FormStatus toFormStatus(string status) {
    const map = [
        "draft": FormStatus.draft,
        "published": FormStatus.published,
        "inactive": FormStatus.inactive,
        "deprecated": FormStatus.deprecated_
    ];
    return map.get(status.toLower, FormStatus.draft);
}

enum FieldType {
    // Field that accepts alphanumeric input, which may include letters, numbers, and special characters based on the process flow and requirements
    text,
    // Field that accepts numeric input, which may include integers, decimals, and negative numbers based on the process flow and requirements
    number,
    // Field that accepts date input, which may include calendar-based selection or manual entry of date values based on the process flow and requirements
    date,
    // Field that accepts date and time input, which may include calendar-based selection or manual entry of date and time values based on the process flow and requirements
    datetime,
    // Field that accepts boolean input, which may include options for true/false, yes/no, or on/off based on the process flow and requirements
    boolean_,
    // Field that allows users to select from a predefined list of options, which may include dropdown menus, combo boxes, or select lists based on the process flow and requirements
    dropdown,
    // Field that allows users to select one option from a predefined list of options, which may include radio buttons based on the process flow and requirements
    radio,
    // Field that allows users to select multiple options from a predefined list of options, which may include checkboxes based on the process flow and requirements
    checkbox,
    // Field that allows users to enter multi-line text input, which may include text areas or rich text editors based on the process flow and requirements
    textarea,
    // Field that allows users to upload files, which may include options for selecting files from their device or dragging and dropping files based on the process flow and requirements
    fileUpload,
    // Field that allows users to input data in a tabular format, which may include options for adding rows and columns based on the process flow and requirements
    table,
    // Field that allows users to input formatted text, which may include options for styling and structuring text based on the process flow and requirements
    paragraph,
    // Field that allows users to input a heading or title, which may include options for different heading levels based on the process flow and requirements
    headline,
    // Field that allows users to input a URL or hyperlink, which may include options for validating the URL format based on the process flow and requirements
    link,
    // Field that allows users to upload or display images, which may include options for selecting images from their device or providing image URLs based on the process flow and requirements
    image,
}

FieldType toFieldType(string type) {
    const map = [
        "text": FieldType.text,
        "number": FieldType.number,
        "date": FieldType.date,
        "datetime": FieldType.datetime,
        "boolean": FieldType.boolean_,
        "dropdown": FieldType.dropdown,
        "radio": FieldType.radio,
        "checkbox": FieldType.checkbox,
        "textarea": FieldType.textarea,
        "file_upload": FieldType.fileUpload,
        "table": FieldType.table,
        "paragraph": FieldType.paragraph,
        "headline": FieldType.headline,
        "link": FieldType.link,
        "image": FieldType.image
    ];
    return map.get(type.toLower, FieldType.text);
}
// --- Automation (RPA Bot) ---

enum AutomationStatus {
    // Used for automations that are being developed and are not yet active, which may indicate that they are still being designed and may require further development and testing before they can be used in production
    draft,
    // Used for automations that have been published and are active, which may indicate that they are ready for use in production and may require monitoring and maintenance to ensure their continued effectiveness and relevance over time
    active,
    // Used for automations that have been temporarily disabled, which may indicate that they are not currently being used in production and may require resolution of underlying issues or conditions before they can be reactivated and used again
    inactive,
    // Used for automations that have encountered errors, which may indicate that they have issues that need to be resolved before they can be reactivated and used again
    error,
}

AutomationStatus toAutomationStatus(string status) {
    const map = [
        "draft": AutomationStatus.draft,
        "active": AutomationStatus.active,
        "inactive": AutomationStatus.inactive,
        "error": AutomationStatus.error
    ];
    return map.get(status.toLower, AutomationStatus.draft);
}

enum AutomationType {
    // Used for automations that are designed to work alongside human users, which may require user interaction and input during the execution of the automation based on the process flow and requirements
    attended,
    // Used for automations that are designed to run independently without human intervention, which may require robust error handling and monitoring to ensure successful execution and timely resolution of any issues that may arise during automation execution based on the process flow and requirements
    unattended,
    // Used for automations that can operate in both attended and unattended modes, which may require flexibility and adaptability to switch between modes based on the process flow and requirements
    hybrid,
    // Used for automations that are designed to be triggered and executed through API calls, which may require integration capabilities and security considerations to ensure proper authentication and authorization based on the process flow and requirements
    api,
}

AutomationType toAutomationType(string type) {
    const map = [
        "attended": AutomationType.attended,
        "unattended": AutomationType.unattended,
        "hybrid": AutomationType.hybrid,
        "api": AutomationType.api
    ];
    return map.get(type.toLower, AutomationType.attended);
}

enum AutomationRunStatus {
    // Used for automation runs that are waiting to be executed, which may indicate that they are in a queue and will be processed based on their priority and the availability of resources based on the process flow and requirements
    queued,
    // Used for automation runs that are currently being executed, which may indicate that they are in progress and may require monitoring and management to ensure successful completion and timely resolution of any issues that may arise during automation execution based on the process flow and requirements
    running,
    // Used for automation runs that have completed successfully, which may indicate that they have fulfilled their intended purpose and may require review or archiving before they can be reactivated or used again based on the process flow and requirements
    completed,
    // Used for automation runs that have encountered errors during execution, which may indicate that they have not fulfilled their intended purpose and may require troubleshooting and resolution before they can be reactivated or used again based on the process flow and requirements
    failed,
    // Used for automation runs that have been intentionally stopped before completion, which may indicate that they were cancelled and may require review or archiving before they can be reactivated or used again based on the process flow and requirements
    cancelled,
    // Used for automation runs that have exceeded their allocated time for execution, which may indicate that they were terminated due to time constraints and may require review and resolution before they can be reactivated or used again based on the process flow and requirements
    timedOut,
}

AutomationRunStatus toAutomationRunStatus(string status) {
    const map = [
        "queued": AutomationRunStatus.queued,
        "running": AutomationRunStatus.running,
        "completed": AutomationRunStatus.completed,
        "failed": AutomationRunStatus.failed,
        "cancelled": AutomationRunStatus.cancelled,
        "timed_out": AutomationRunStatus.timedOut
    ];
    return map.get(status.toLower, AutomationRunStatus.queued);
}
// --- Trigger ---

enum TriggerType {
    // Used for triggers that are initiated manually by users, which may indicate that they require user interaction and input to start the process based on the process flow and requirements
    manual,
    // Used for triggers that are scheduled to run at specific times or intervals, which may indicate that they require scheduling capabilities and time-based execution based on the process flow and requirements
    scheduled,
    // Used for triggers that are initiated through API calls, which may indicate that they require integration capabilities and security considerations to ensure proper authentication and authorization based on the process flow and requirements
    api,
    // Used for triggers that are initiated based on specific events or conditions, which may indicate that they require event detection and handling capabilities to respond to relevant events or conditions based on the process flow and requirements
    event,
    // Used for triggers that are initiated based on incoming emails, which may indicate that they require email integration capabilities and parsing logic to extract relevant information from the emails based on the process flow and requirements
    email,
    // Used for triggers that are initiated based on incoming webhook requests, which may indicate that they require webhook integration capabilities and parsing logic to extract relevant information from the requests based on the process flow and requirements
    webhook,
    // Used for triggers that are initiated based on form submissions, which may indicate that they require form integration capabilities and parsing logic to extract relevant information from the submitted forms based on the process flow and requirements
    formSubmission,
}

TriggerType toTriggerType(string type) {
    const map = [
        "manual": TriggerType.manual,
        "scheduled": TriggerType.scheduled,
        "api": TriggerType.api,
        "event": TriggerType.event,
        "email": TriggerType.email,
        "webhook": TriggerType.webhook,
        "form_submission": TriggerType.formSubmission
    ];
    return map.get(type.toLower, TriggerType.manual);
}

enum TriggerStatus {
    // Used for triggers that are active and can initiate the process, which may indicate that they are ready for use in production and may require monitoring and maintenance to ensure their continued effectiveness and relevance over time based on the process flow and requirements
    active,
    // Used for triggers that have been temporarily disabled, which may indicate that they are not currently being used in production and may require resolution of underlying issues or conditions before they can be reactivated and used again based on the process flow and requirements
    inactive,
    // Used for triggers that have encountered errors, which may indicate that they have issues that need to be resolved before they can be reactivated and used again based on the process flow and requirements
    error,
}

TriggerStatus toTriggerStatus(string status) {
    const map = [
        "active": TriggerStatus.active,
        "inactive": TriggerStatus.inactive,
        "error": TriggerStatus.error
    ];
    return map.get(status.toLower, TriggerStatus.inactive);
}

enum ScheduleFrequency {
    // Used for triggers that are scheduled to run only
    once,
    // Used for triggers that are scheduled to run every minute, which may indicate that they require frequent execution based on the process flow and requirements
    minutely,
    // Used for triggers that are scheduled to run every hour, which may indicate that they require regular execution based on the process flow and requirements
    hourly,
    // Used for triggers that are scheduled to run every day, which may indicate that they require daily execution based on the process flow and requirements
    daily,
    // Used for triggers that are scheduled to run every week, which may indicate that they require weekly execution based on the process flow and requirements
    weekly,
    // Used for triggers that are scheduled to run every month, which may indicate that they require monthly execution based on the process flow and requirements
    monthly,
    // Used for triggers that are scheduled to run every year, which may indicate that they require yearly execution based on the process flow and requirements
    yearly,
    // Used for triggers that are scheduled to run based on a cron expression, which may indicate that they require complex scheduling based on specific time patterns defined in the cron expression according to the process flow and requirements
    cron,
}

ScheduleFrequency toScheduleFrequency(string freq) {
    const map = [
        "once": ScheduleFrequency.once,
        "minutely": ScheduleFrequency.minutely,
        "hourly": ScheduleFrequency.hourly,
        "daily": ScheduleFrequency.daily,
        "weekly": ScheduleFrequency.weekly,
        "monthly": ScheduleFrequency.monthly,
        "yearly": ScheduleFrequency.yearly,
        "cron": ScheduleFrequency.cron
    ];
    return map.get(freq.toLower, ScheduleFrequency.once);
}
// --- Action (Integration) ---

enum ActionStatus {
    // Used for actions that are being developed and are not yet active, which may indicate that they are still being designed and may require further development and testing before they can be used in production
    draft,
    // Used for actions that have been published and are active, which may indicate that they are ready for use in production and may require monitoring and maintenance to ensure their continued effectiveness and relevance over time
    active,
    // Used for actions that have been temporarily disabled, which may indicate that they are not currently being used in production and may require resolution of underlying issues or conditions before they can be reactivated and used again
    inactive,
    // Used for actions that have encountered errors, which may indicate that they have issues that need to be resolved before they can be reactivated and used again
    error,
}

ActionStatus toActionStatus(string status) {
    const map = [
        "draft": ActionStatus.draft,
        "active": ActionStatus.active,
        "inactive": ActionStatus.inactive,
        "error": ActionStatus.error
    ];
    return map.get(status.toLower, ActionStatus.draft);
}

enum ActionType {
    // Used for actions that are designed to interact with RESTful APIs, which may require configuration of endpoints, authentication, and request/response handling based on the process flow and requirements
    restApi,
    // Used for actions that are designed to interact with OData services, which may require configuration of service endpoints, authentication, and query handling based on the process flow and requirements
    odata,
    // Used for actions that are designed to interact with SAP systems using Remote Function Calls (RFC), which may require configuration of SAP connection parameters, authentication, and function module handling based on the process flow and requirements
    rfc,
    // Used for actions that are designed to interact with SOAP-based web services, which may require configuration of service endpoints, authentication, and XML handling based on the process flow and requirements
    soap,
    // Used for actions that are designed to interact with GraphQL APIs, which may require configuration of endpoints, authentication, and query/mutation handling based on the process flow and requirements
    graphql,
    // Used for actions that represent a custom or specialized type that does not fit into any of the above types, which may require custom handling and processing based on specific business requirements or use cases
    custom,
}

ActionType toActionType(string type) {
    const map = [
        "rest_api": ActionType.restApi,
        "odata": ActionType.odata,
        "rfc": ActionType.rfc,
        "soap": ActionType.soap,
        "graphql": ActionType.graphql,
        "custom": ActionType.custom
    ];
    return map.get(type.toLower, ActionType.custom);
}
// --- Alerting and Monitoring ---

// --- Visibility (Process Monitoring) ---

enum VisibilityStatus {
    // Used for entities that are active and visible in the system, which may indicate that they are currently being used in production and may require monitoring and maintenance to ensure their continued effectiveness and relevance over time based on the process flow and requirements
    active,
    // Used for entities that have been temporarily disabled and are not visible in the system, which may indicate that they are not currently being used in production and may require resolution of underlying issues or conditions before they can be reactivated and made visible again based on the process flow and requirements
    inactive,
    // Used for entities that have encountered errors and are not visible in the system, which may indicate that they have issues that need to be resolved before they can be reactivated and made visible again based on the process flow and requirements
    error,
}

VisibilityStatus toVisibilityStatus(string status) {
    const map = [
        "active": VisibilityStatus.active,
        "inactive": VisibilityStatus.inactive,
        "error": VisibilityStatus.error
    ];
    return map.get(status.toLower, VisibilityStatus.inactive);
}

enum DashboardType {
    // Used for dashboards that provide an overview of the entire process, which may include high-level metrics, key performance indicators (KPIs), and visualizations to monitor the overall health and performance of the process based on the process flow and requirements
    processOverview,
    // Used for dashboards that provide detailed information about individual process instances, which may include instance-level metrics, timelines, and visualizations to monitor the progress and status of specific instances based on the process flow and requirements
    instanceDetail,
    // Used for dashboards that provide insights and analysis on task-level data, which may include task metrics, bottleneck analysis, and visualizations to monitor the performance and efficiency of tasks within the process based on the process flow and requirements
    taskAnalytics,
    // Used for dashboards that focus on key performance indicators (KPIs) related to the process, which may include metrics such as cycle time, throughput, and efficiency to monitor the performance and effectiveness of the process based on the process flow and requirements
    performanceKpi,
    // Used for dashboards that analyze bottlenecks and identify areas of improvement within the process, which may include metrics such as wait times, queue lengths, and resource utilization to monitor and optimize the flow of the process based on the process flow and requirements
    bottleneckAnalysis,
    // Used for dashboards that monitor service level agreement (SLA) compliance, which may include metrics such as SLA adherence, breach rates, and response times to monitor and ensure that the process is meeting its defined SLAs based on the process flow and requirements
    slaCompliance,
    // Used for dashboards that represent a custom or specialized type that does not fit into any of the above types, which may require custom design and configuration based on specific business requirements or use cases
    custom,
}

DashboardType toDashboardType(string type) {
    const map = [
        "process_overview": DashboardType.processOverview,
        "instance_detail": DashboardType.instanceDetail,
        "task_analytics": DashboardType.taskAnalytics,
        "performance_kpi": DashboardType.performanceKpi,
        "bottleneck_analysis": DashboardType.bottleneckAnalysis,
        "sla_compliance": DashboardType.slaCompliance,
        "custom": DashboardType.custom
    ];
    return map.get(type.toLower, DashboardType.custom);
}

enum MetricType {
    // Metric that counts the number of occurrences or instances of a specific event, action, or condition within the process, which may indicate the frequency or volume of certain activities based on the process flow and requirements
    count,
    // Metric that calculates the average value of a specific numerical attribute or measure within the process, which may indicate the typical or central tendency of certain data points based on the process flow and requirements
    average,
    // Metric that calculates the total sum of a specific numerical attribute or measure within the process, which may indicate the overall magnitude or total value of certain data points based on the process flow and requirements
    sum,
    // Metric that identifies the minimum value of a specific numerical attribute or measure within the process, which may indicate the lowest or smallest value among certain data points based on the process flow and requirements
    min_,
    // Metric that identifies the maximum value of a specific numerical attribute or measure within the process, which may indicate the highest or largest value among certain data points based on the process flow and requirements
    max_,
    // Metric that calculates the percentage or proportion of a specific event, action, or condition relative to a defined total or baseline within the process, which may indicate the relative frequency or significance of certain activities based on the process flow and requirements
    percentage,
    // Metric that measures the time taken to complete a specific event, action, or process within the process, which may indicate the duration or efficiency of certain activities based on the process flow and requirements
    duration,
}

MetricType toMetricType(string type) {
    const map = [
        "count": MetricType.count,
        "average": MetricType.average,
        "sum": MetricType.sum,
        "min": MetricType.min_,
        "max": MetricType.max_,
        "percentage": MetricType.percentage,
        "duration": MetricType.duration
    ];
    return map.get(type.toLower, MetricType.count);
}
// --- Artifact Store ---

enum ArtifactType {
    // Artifact that represents a reusable process template, which may include predefined process models, configurations, and best practices that can be used to accelerate the design and implementation of new processes based on the process flow and requirements
    processTemplate,
    // Artifact that represents a reusable bot template, which may include predefined automation scripts, configurations, and best practices that can be used to accelerate the design and implementation of new automations based on the process flow and requirements
    botTemplate,
    // Artifact that represents a reusable form template, which may include predefined form designs, configurations, and best practices that can be used to accelerate the design and implementation of new forms based on the process flow and requirements
    formTemplate,
    // Artifact that represents a reusable decision template, which may include predefined decision models, configurations, and best practices that can be used to accelerate the design and implementation of new decisions based on the process flow and requirements
    decisionTemplate,
    // Artifact that represents a reusable action template, which may include predefined integration configurations, scripts, and best practices that can be used to accelerate the design and implementation of new actions based on the process flow and requirements
    actionTemplate,
    // Artifact that represents a reusable connector, which may include predefined configurations, scripts, and best practices for connecting to external systems or services that can be used to accelerate the design and implementation of new connectors based on the process flow and requirements
    connector,
    // Artifact that represents a reusable plugin, which may include predefined configurations, scripts, and best practices for extending the functionality of the platform that can be used to accelerate the design and implementation of new plugins based on the process flow and requirements
    plugin,
}

ArtifactType toArtifactType(string type) {
    const map = [
        "process_template": ArtifactType.processTemplate,
        "bot_template": ArtifactType.botTemplate,
        "form_template": ArtifactType.formTemplate,
        "decision_template": ArtifactType.decisionTemplate,
        "action_template": ArtifactType.actionTemplate,
        "connector": ArtifactType.connector,
        "plugin": ArtifactType.plugin
    ];
    return map.get(type.toLower, ArtifactType.processTemplate);
}

enum ArtifactStatus {
    // Artifact that is available in the artifact store and can be used for new instances, which may indicate that it is ready for use in production and may require monitoring and maintenance to ensure its continued effectiveness and relevance over time based on the process flow and requirements
    available,
    // Artifact that has been installed and is currently being used in production, which may indicate that it is active and may require monitoring and maintenance to ensure its continued effectiveness and relevance over time based on the process flow and requirements
    installed,
    // Artifact that has an update available, which may indicate that there is a newer version of the artifact with improvements or bug fixes that can be installed to enhance its functionality and performance based on the process flow and requirements
    updateAvailable,
    // Artifact that has been deprecated and should not be used for new instances, but existing ones can continue to use them, which may require review and archiving before they can be reactivated or used again based on the process flow and requirements
    deprecated_,
}

ArtifactStatus toArtifactStatus(string status) {
    const map = [
        "available": ArtifactStatus.available,
        "installed": ArtifactStatus.installed,
        "update_available": ArtifactStatus.updateAvailable,
        "deprecated": ArtifactStatus.deprecated_
    ];
    return map.get(status.toLower, ArtifactStatus.available);
}
