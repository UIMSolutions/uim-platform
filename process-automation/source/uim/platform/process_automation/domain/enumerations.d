/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.enumerations;

import uim.platform.process_automation;

mixin(ShowModule!());

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
    mixin(EnumSwitch("ProcessStatus", "unknown"));
}

ProcessStatus[] toProcessStatuses(string[] statuses)
    => statuses.map!toProcessStatus.array;

string toString(ProcessStatus status)
    => status.to!string;

string[] toStrings(ProcessStatus[] statuses)
    => statuses.map!toString.array;
///
unittest {
    mixin(ShowTest!("ProcessStatus"));

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

    assert(toProcessStatus("") == ProcessStatus.unknown);
    assert(toProcessStatus("unknown_status") == ProcessStatus.unknown);

    assert(ProcessStatus.active.toString == "active");
    assert(ProcessStatus.inactive.toString == "inactive");
    assert(ProcessStatus.deprecated_.toString == "deprecated");
    assert(ProcessStatus.error.toString == "error");
    assert(ProcessStatus.archived.toString == "archived");
    assert(ProcessStatus.unknown.toString == "unknown");
    assert(ProcessStatus.deleted.toString == "deleted");
    assert(ProcessStatus.suspended.toString == "suspended");
    assert(ProcessStatus.completed.toString == "completed");
    assert(ProcessStatus.failed.toString == "failed");
    assert(ProcessStatus.cancelled.toString == "cancelled");
    assert(ProcessStatus.waiting.toString == "waiting");
    assert(ProcessStatus.terminated.toString == "terminated");
    assert(ProcessStatus.resumed.toString == "resumed");
    assert(ProcessStatus.rollingBack.toString == "rollingBack");
    assert(ProcessStatus.rolledBack.toString == "rolledBack");
    assert(ProcessStatus.migrating.toString == "migrating");
    assert(ProcessStatus.migrated.toString == "migrated");
    assert(ProcessStatus.versioning.toString == "versioning");
    assert(ProcessStatus.versioned.toString == "versioned");
    assert(ProcessStatus.cloning.toString == "cloning");
    assert(ProcessStatus.cloned.toString == "cloned");
    assert(ProcessStatus.testing.toString == "testing");
    assert(ProcessStatus.tested.toString == "tested");
    assert(ProcessStatus.validating.toString == "validating");
    assert(ProcessStatus.validated.toString == "validated");
    assert(ProcessStatus.releasing.toString == "releasing");
    assert(ProcessStatus.released.toString == "released");

    assert(["active", "inactive", "deprecated"].toProcessStatuses == [
            ProcessStatus.active, ProcessStatus.inactive,
            ProcessStatus.deprecated_
        ]);
    assert([
        ProcessStatus.active, ProcessStatus.inactive, ProcessStatus.deprecated_
    ].toStrings == [
        "active", "inactive", "deprecated"
    ]);
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
    mixin(EnumSwitch("ProcessCategory", "custom"));
}

ProcessCategory[] toProcessCategories(string[] categories)
    => categories.map!toProcessCategory.array;

string toString(ProcessCategory category)
    => category.to!string;

string[] toStrings(ProcessCategory[] categories)
    => categories.map!toString.array;
///
unittest {
    mixin(ShowTest!("ProcessCategory"));

    assert("workflow".toProcessCategory == ProcessCategory.workflow);
    assert("approval".toProcessCategory == ProcessCategory.approval);
    assert("notification".toProcessCategory == ProcessCategory.notification);
    assert("automation".toProcessCategory == ProcessCategory.automation);
    assert("hybrid".toProcessCategory == ProcessCategory.hybrid);
    assert("custom".toProcessCategory == ProcessCategory.custom);

    assert("".toProcessCategory == ProcessCategory.custom);
    assert("unknown".toProcessCategory == ProcessCategory.custom);

    assert(ProcessCategory.workflow.toString == "workflow");
    assert(ProcessCategory.approval.toString == "approval");
    assert(ProcessCategory.notification.toString == "notification");
    assert(ProcessCategory.automation.toString == "automation");
    assert(ProcessCategory.hybrid.toString == "hybrid");
    assert(ProcessCategory.custom.toString == "custom");

    assert(["workflow", "approval", "notification"].toProcessCategories == [
            ProcessCategory.workflow, ProcessCategory.approval,
            ProcessCategory.notification
        ]);
    assert([
        ProcessCategory.workflow, ProcessCategory.approval,
        ProcessCategory.notification
    ].toStrings == [
        "workflow", "approval", "notification"
    ]);
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
    mixin(EnumSwitch("StepType", "custom"));
}

StepType[] toStepTypes(string[] types)
    => types.map!toStepType.array;

string toString(StepType type)
    => type.to!string;

string[] toStrings(StepType[] types)
    => types.map!toString.array;

///
unittest {
    mixin(ShowTest!("StepType"));

    assert(toStepType("startEvent") == StepType.startEvent);
    assert(toStepType("endEvent") == StepType.endEvent);
    assert(toStepType("userTask") == StepType.userTask);
    assert(toStepType("serviceTask") == StepType.serviceTask);
    assert(toStepType("scriptTask") == StepType.scriptTask);
    assert(toStepType("decisionTask") == StepType.decisionTask);
    assert(toStepType("automationTask") == StepType.automationTask);
    assert(toStepType("mailTask") == StepType.mailTask);
    assert(toStepType("parallelGateway") == StepType.parallelGateway);
    assert(toStepType("exclusiveGateway") == StepType.exclusiveGateway);
    assert(toStepType("inclusiveGateway") == StepType.inclusiveGateway);
    assert(toStepType("eventBasedGateway") == StepType.eventBasedGateway);
    assert(toStepType("subProcess") == StepType.subProcess);
    assert(toStepType("callActivity") == StepType.callActivity);
    assert(toStepType("timerEvent") == StepType.timerEvent);
    assert(toStepType("messageEvent") == StepType.messageEvent);
    assert(toStepType("signalEvent") == StepType.signalEvent);
    assert(toStepType("errorEvent") == StepType.errorEvent);
    assert(toStepType("condition") == StepType.condition);
    assert(toStepType("custom") == StepType.custom);

    assert(toStepType("") == StepType.custom);
    assert(toStepType("unknown") == StepType.custom);

    assert(StepType.startEvent.toString == "startEvent");
    assert(StepType.endEvent.toString == "endEvent");
    assert(StepType.userTask.toString == "userTask");
    assert(StepType.serviceTask.toString == "serviceTask");
    assert(StepType.scriptTask.toString == "scriptTask");
    assert(StepType.decisionTask.toString == "decisionTask");
    assert(StepType.automationTask.toString == "automationTask");
    assert(StepType.mailTask.toString == "mailTask");
    assert(StepType.parallelGateway.toString == "parallelGateway");
    assert(StepType.exclusiveGateway.toString == "exclusiveGateway");
    assert(StepType.inclusiveGateway.toString == "inclusiveGateway");
    assert(StepType.eventBasedGateway.toString == "eventBasedGateway");
    assert(StepType.subProcess.toString == "subProcess");
    assert(StepType.callActivity.toString == "callActivity");
    assert(StepType.timerEvent.toString == "timerEvent");
    assert(StepType.messageEvent.toString == "messageEvent");
    assert(StepType.signalEvent.toString == "signalEvent");
    assert(StepType.errorEvent.toString == "errorEvent");
    assert(StepType.condition.toString == "condition");
    assert(StepType.custom.toString == "custom");

    assert(["startEvent", "endEvent", "userTask"].toStepTypes == [
            StepType.startEvent, StepType.endEvent, StepType.userTask
        ]);
    assert([StepType.startEvent, StepType.endEvent, StepType.userTask].toStrings == [
            "startEvent", "endEvent", "userTask"
        ]);
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
    mixin(EnumSwitch("InstanceStatus", "unknown"));
}

InstanceStatus[] toInstanceStatuses(string[] statuses)
    => statuses.map!toInstanceStatus.array;

string toString(InstanceStatus status)
    => status.to!string;

string[] toStrings(InstanceStatus[] statuses)
    => statuses.map!toString.array;
///
unittest {
    mixin(ShowTest!("InstanceStatus"));

    assert("running".toInstanceStatus == InstanceStatus.running);
    assert("completed".toInstanceStatus == InstanceStatus.completed);
    assert("failed".toInstanceStatus == InstanceStatus.failed);
    assert("suspended".toInstanceStatus == InstanceStatus.suspended);
    assert("cancelled".toInstanceStatus == InstanceStatus.cancelled);
    assert("waiting".toInstanceStatus == InstanceStatus.waiting);
    assert("error".toInstanceStatus == InstanceStatus.error);
    assert("unknown".toInstanceStatus == InstanceStatus.unknown);

    assert("".toInstanceStatus == InstanceStatus.unknown);
    assert("some_unknown_status".toInstanceStatus == InstanceStatus.unknown);

    assert(InstanceStatus.running.toString == "running");
    assert(InstanceStatus.completed.toString == "completed");
    assert(InstanceStatus.failed.toString == "failed");
    assert(InstanceStatus.suspended.toString == "suspended");
    assert(InstanceStatus.cancelled.toString == "cancelled");
    assert(InstanceStatus.waiting.toString == "waiting");
    assert(InstanceStatus.error.toString == "error");
    assert(InstanceStatus.unknown.toString == "unknown");

    assert(["running", "completed", "failed"].toInstanceStatuses == [
            InstanceStatus.running, InstanceStatus.completed,
            InstanceStatus.failed
        ]);

    assert([
        InstanceStatus.running, InstanceStatus.completed, InstanceStatus.failed
    ].toStrings == [
        "running", "completed", "failed"
    ]);
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
    mixin(EnumSwitch("InstancePriority", "medium"));
}

InstancePriority[] toInstancePriorities(string[] priorities)
    => priorities.map!toInstancePriority.array;

string toString(InstancePriority priority)
    => priority.to!string;

string[] toStrings(InstancePriority[] priorities)
    => priorities.map!toString.array;

/// 
unittest {
    mixin(ShowTest!("InstancePriority"));

    assert("low".toInstancePriority == InstancePriority.low);
    assert("medium".toInstancePriority == InstancePriority.medium);
    assert("high".toInstancePriority == InstancePriority.high);
    assert("critical".toInstancePriority == InstancePriority.critical);

    assert("".toInstancePriority == InstancePriority.medium);
    assert("some_unknown_priority".toInstancePriority == InstancePriority.medium);

    assert(InstancePriority.low.toString == "low");
    assert(InstancePriority.medium.toString == "medium");
    assert(InstancePriority.high.toString == "high");
    assert(InstancePriority.critical.toString == "critical");

    assert(["low", "medium", "high"].toInstancePriorities == [
            InstancePriority.low, InstancePriority.medium, InstancePriority.high
        ]);

    assert([
        InstancePriority.low, InstancePriority.medium, InstancePriority.high
    ].toStrings == [
        "low", "medium", "high"
    ]);
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

EventCategory[] toEventCategories(string[] categories)
    => categories.map!toEventCategory.array;

string toString(EventCategory category)
    => category.to!string;

string[] toStrings(EventCategory[] categories)
    => categories.map!toString.array;

///
unittest {
    mixin(ShowTest!("EventCategory"));

    assert("NOTIFICATION".toEventCategory == EventCategory.notification);
    assert("ALERT".toEventCategory == EventCategory.alert);
    assert("EXCEPTION".toEventCategory == EventCategory.exception_);
    assert("CUSTOM".toEventCategory == EventCategory.custom);

    assert("".toEventCategory == EventCategory.notification);
    assert("some_unknown_category".toEventCategory == EventCategory.notification);

    assert(EventCategory.notification.toString == "notification");
    assert(EventCategory.alert.toString == "alert");
    assert(EventCategory.exception_.toString == "exception_");
    assert(EventCategory.custom.toString == "custom");

    assert(["NOTIFICATION", "ALERT", "EXCEPTION"].toEventCategories == [
            EventCategory.notification, EventCategory.alert,
            EventCategory.exception_
        ]);

    assert([
        EventCategory.notification, EventCategory.alert, EventCategory.exception_
    ].toStrings == [
        "notification", "alert", "exception_"
    ]);
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
    mixin(EnumSwitch("TaskStatus", "unknown"));
}

TaskStatus[] toTaskStatuses(string[] statuses)
    => statuses.map!toTaskStatus.array;

string toString(TaskStatus status)
    => status.to!string;

string[] toStrings(TaskStatus[] statuses)
    => statuses.map!toString.array;

/// 
unittest {
    mixin(ShowTest!("TaskStatus"));

    assert("ready".toTaskStatus == TaskStatus.ready);
    assert("reserved".toTaskStatus == TaskStatus.reserved);
    assert("inProgress".toTaskStatus == TaskStatus.inProgress);
    assert("completed".toTaskStatus == TaskStatus.completed);
    assert("failed".toTaskStatus == TaskStatus.failed);
    assert("cancelled".toTaskStatus == TaskStatus.cancelled);
    assert("forwarded".toTaskStatus == TaskStatus.forwarded);
    assert("unknown".toTaskStatus == TaskStatus.unknown);

    assert("".toTaskStatus == TaskStatus.unknown);
    assert("some_unknown_status".toTaskStatus == TaskStatus.unknown);

    assert(TaskStatus.ready.toString == "ready");
    assert(TaskStatus.reserved.toString == "reserved");
    assert(TaskStatus.inProgress.toString == "inProgress");
    assert(TaskStatus.completed.toString == "completed");
    assert(TaskStatus.failed.toString == "failed");
    assert(TaskStatus.cancelled.toString == "cancelled");
    assert(TaskStatus.forwarded.toString == "forwarded");
    assert(TaskStatus.unknown.toString == "unknown");

    assert(["ready", "reserved", "inProgress"].toTaskStatuses == [
            TaskStatus.ready, TaskStatus.reserved, TaskStatus.inProgress
        ]);

    assert([TaskStatus.ready, TaskStatus.reserved, TaskStatus.inProgress].toStrings == [
            "ready", "reserved", "inProgress"
        ]);
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
    mixin(EnumSwitch("TaskPriority", "unknown"));
}

TaskPriority[] toTaskPriorities(string[] priorities)
    => priorities.map!toTaskPriority.array;

string toString(TaskPriority priority)
    => priority.to!string;

string[] toStrings(TaskPriority[] priorities)
    => priorities.map!toString.array;
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
    mixin(EnumSwitch("TaskType", "custom"));
}

TaskType[] toTaskTypes(string[] types)
    => types.map!(t => toTaskType(t)).array;

string toString(TaskType type)
    => type.to!string;

string[] toStrings(TaskType[] types)
    => types.map!toString.array;

///
unittest {
    assert(toString(TaskType.approval) == "approval");
    assert(toString(TaskType.review) == "review");
    assert(toString(TaskType.form) == "form");
    assert(toString(TaskType.decision) == "decision");
    assert(toString(TaskType.notification) == "notification");
    assert(toString(TaskType.custom) == "custom");
}

// --- Decision (Business Rules) ---

enum DecisionStatus : string {
    // Decision has  been created but not yet published, which may indicate that it is still being designed and may require further development and testing before it can be used in production
    draft = "draft",
    // Decision has been published and is active, which may indicate that it is ready for use in production and may require monitoring and maintenance to ensure its continued effectiveness and relevance over time
    active = "active",
    // Decision has been temporarily disabled, which may indicate that it is not currently being used in production and may require resolution of underlying issues or conditions before it can be reactivated and used again
    inactive = "inactive",
    // Decision has been deprecated, which may indicate that it should not be used for new instances, but existing ones can continue to use them, which may require review and archiving before they can be reactivated or used again
    deprecated_ = "deprecated",
}

DecisionStatus toDecisionStatus(string value) {
    switch (value.toLower) {
    case "draft":
        return DecisionStatus.draft;
    case "active":
        return DecisionStatus.active;
    case "inactive":
        return DecisionStatus.inactive;
    case "deprecated":
        return DecisionStatus.deprecated_;
    default:
        return DecisionStatus.draft;
    }
}

DecisionStatus[] toDecisionStatuses(string[] values)
    => values.map!(v => toDecisionStatus(v)).array;

string toString(DecisionStatus status)
    => cast(string)status;

string[] toStrings(DecisionStatus[] statuses)
    => statuses.map!toString.array;

/// 
unittest {
    mixin(ShowTest!("DecisionStatus"));

    assert("draft".toDecisionStatus == DecisionStatus.draft);
    assert("active".toDecisionStatus == DecisionStatus.active);
    assert("inactive".toDecisionStatus == DecisionStatus.inactive);
    assert("deprecated".toDecisionStatus == DecisionStatus.deprecated_);

    assert("".toDecisionStatus == DecisionStatus.draft);
    assert("some_unknown_status".toDecisionStatus == DecisionStatus.draft);

    assert(DecisionStatus.draft.toString == "draft");
    assert(DecisionStatus.active.toString == "active");
    assert(DecisionStatus.inactive.toString == "inactive");
    assert(DecisionStatus.deprecated_.toString == "deprecated");

    assert(["draft", "active", "inactive"].toDecisionStatuses == [
            DecisionStatus.draft, DecisionStatus.active,
            DecisionStatus.inactive
        ]);

    assert([
        DecisionStatus.draft, DecisionStatus.active, DecisionStatus.inactive
    ].toStrings == [
        "draft", "active", "inactive"
    ]);
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

DecisionType toDecisionType(string value) {
    mixin(EnumSwitch("DecisionType", "decisionTable"));
}

DecisionType[] toDecisionTypes(string[] values)
    => values.map!toDecisionType.array;

string toString(DecisionType type)
    => type.to!string;

string[] toStrings(DecisionType[] types)
    => types.map!toString.array;

///
unittest {

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
    mixin(EnumSwitch("HitPolicy", "first"));
}

HitPolicy[] toHitPolicies(string[] policies)
    => policies.map!toHitPolicy.array;

string toString(HitPolicy policy)
    => policy.to!string;

string[] toStrings(HitPolicy[] policies)
    => policies.map!toString.array;

/// 
unittest {
    mixin(ShowTest!("HitPolicy"));

    assert("first".toHitPolicy == HitPolicy.first);
    assert("any".toHitPolicy == HitPolicy.any);
    assert("priority".toHitPolicy == HitPolicy.priority);
    assert("unique".toHitPolicy == HitPolicy.unique);
    assert("collect".toHitPolicy == HitPolicy.collect);
    assert("ruleOrder".toHitPolicy == HitPolicy.ruleOrder);
    assert("outputOrder".toHitPolicy == HitPolicy.outputOrder);

    assert("".toHitPolicy == HitPolicy.first);
    assert("unknown".toHitPolicy == HitPolicy.first);

    assert(HitPolicy.first.toString == "first");
    assert(HitPolicy.any.toString == "any");
    assert(HitPolicy.priority.toString == "priority");
    assert(HitPolicy.unique.toString == "unique");
    assert(HitPolicy.collect.toString == "collect");
    assert(HitPolicy.ruleOrder.toString == "ruleOrder");
    assert(HitPolicy.outputOrder.toString == "outputOrder");

    assert([
        "first", "any", "priority", "unique", "collect", "ruleOrder",
        "outputOrder"
    ].toHitPolicies == [
        HitPolicy.first, HitPolicy.any, HitPolicy.priority, HitPolicy.unique,
        HitPolicy.collect, HitPolicy.ruleOrder, HitPolicy.outputOrder
    ]);
    assert([
        HitPolicy.first, HitPolicy.any, HitPolicy.priority, HitPolicy.unique,
        HitPolicy.collect, HitPolicy.ruleOrder, HitPolicy.outputOrder
    ].toStrings == [
        "first", "any", "priority", "unique", "collect", "ruleOrder",
        "outputOrder"
    ]);
}

enum ConditionType : string {
    // Condition that checks for equality between values, which may indicate that the values must be the same for the condition to be satisfied based on the process flow and requirements
    equals = "equals",
    // Condition that checks for inequality between values, which may indicate that the values must be different for the condition to be satisfied based on the process flow and requirements
    notEquals = "not_equals",
    // Condition that checks if a value is greater than another value, which may indicate that the first value must be larger than the second value for the condition to be satisfied based on the process flow and requirements
    greaterThan = "greater_than",
    // Condition that checks if a value is less than another value, which may indicate that the first value must be smaller than the second value for the condition to be satisfied based on the process flow and requirements
    lessThan = "less_than",
    // Condition that checks if a value is greater than or equal to another value, which may indicate that the first value must be larger than or equal to the second value for the condition to be satisfied based on the process flow and requirements
    greaterOrEqual = "greater_or_equal",
    // Condition that checks if a value is less than or equal to another value, which may indicate that the first value must be smaller than or equal to the second value for the condition to be satisfied based on the process flow and requirements
    lessOrEqual = "less_or_equal",
    // Condition that checks if a value falls within a specified range between two values, which may indicate that the value must be greater than or equal to the lower bound and less than or equal to the upper bound for the condition to be satisfied based on the process flow and requirements
    between = "between",
    // Condition that checks if a value contains a specified substring, which may indicate that the value must include the substring for the condition to be satisfied based on the process flow and requirements
    contains = "contains",
    // Condition that checks if a value starts with a specified substring, which may indicate that the value must begin with the substring for the condition to be satisfied based on the process flow and requirements
    startsWith = "starts_with",
    // Condition that checks if a value ends with a specified substring, which may indicate that the value must end with the substring for the condition to be satisfied based on the process flow and requirements
    endsWith = "ends_with",
    // Condition that checks if a value is within a specified set of values, which may indicate that the value must be one of the specified values for the condition to be satisfied based on the process flow and requirements
    in_ = "in",
    // Condition that checks if a value is not within a specified set of values, which may indicate that the value must not be one of the specified values for the condition to be satisfied based on the process flow and requirements
    notIn = "not_in",
}

ConditionType toConditionType(string value) {
    switch (value.toLower) {
    case "equals":
        return ConditionType.equals;
    case "not_equals":
        return ConditionType.notEquals;
    case "greater_than":
        return ConditionType.greaterThan;
    case "less_than":
        return ConditionType.lessThan;
    case "greater_or_equal":
        return ConditionType.greaterOrEqual;
    case "less_or_equal":
        return ConditionType.lessOrEqual;
    case "between":
        return ConditionType.between;
    case "contains":
        return ConditionType.contains;
    case "starts_with":
        return ConditionType.startsWith;
    case "ends_with":
        return ConditionType.endsWith;
    case "in":
        return ConditionType.in_;
    case "not_in":
        return ConditionType.notIn;
    default:
        return ConditionType.equals;
    }
}

ConditionType[] toConditionTypes(string[] values)
    => values.map!toConditionType.array;

string toString(ConditionType type)
    => cast(string)type;

string[] toStrings(ConditionType[] types)
    => types.map!toString.array;

///
unittest {
    mixin(ShowTest!("ConditionType"));

    assert("equals".toConditionType == ConditionType.equals);
    assert("not_equals".toConditionType == ConditionType.notEquals);
    assert("greater_than".toConditionType == ConditionType.greaterThan);
    assert("less_than".toConditionType == ConditionType.lessThan);
    assert("greater_or_equal".toConditionType == ConditionType.greaterOrEqual);
    assert("less_or_equal".toConditionType == ConditionType.lessOrEqual);
    assert("between".toConditionType == ConditionType.between);
    assert("contains".toConditionType == ConditionType.contains);
    assert("starts_with".toConditionType == ConditionType.startsWith);
    assert("ends_with".toConditionType == ConditionType.endsWith);
    assert("in".toConditionType == ConditionType.in_);
    assert("not_in".toConditionType == ConditionType.notIn);

    assert("".toConditionType == ConditionType.equals);
    assert("some_unknown_condition".toConditionType == ConditionType.equals);

    assert(ConditionType.equals.toString == "equals");
    assert(ConditionType.notEquals.toString == "not_equals");
    assert(ConditionType.greaterThan.toString == "greater_than");
    assert(ConditionType.lessThan.toString == "less_than");
    assert(ConditionType.greaterOrEqual.toString == "greater_or_equal");
    assert(ConditionType.lessOrEqual.toString == "less_or_equal");
    assert(ConditionType.between.toString == "between");
    assert(ConditionType.contains.toString == "contains");
    assert(ConditionType.startsWith.toString == "starts_with");
    assert(ConditionType.endsWith.toString == "ends_with");
    assert(ConditionType.in_.toString == "in");
    assert(ConditionType.notIn.toString == "not_in");

    assert([
        ConditionType.equals, ConditionType.notEquals, ConditionType.greaterThan
    ].toStrings == [
        "equals", "not_equals", "greater_than"
    ]);

    assert(["equals", "not_equals", "greater_than"].toConditionTypes == [
            ConditionType.equals, ConditionType.notEquals,
            ConditionType.greaterThan
        ]);
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

FormStatus toFormStatus(string value) {
    switch (value.toLower) {
    case "draft":
        return FormStatus.draft;
    case "published":
        return FormStatus.published;
    case "inactive":
        return FormStatus.inactive;
    case "deprecated":
        return FormStatus.deprecated_;
    case "archived":
        return FormStatus.archived;
    case "error":
        return FormStatus.error;
    default:
        return FormStatus.draft;
    }
}

FormStatus[] toFormStatuses(string[] values)
    => values.map!(v => toFormStatus(v)).array;

string toString(FormStatus status)
    => cast(string)status;

string[] toStrings(FormStatus[] statuses)
    => statuses.map!toString.array;

///
unittest {
    mixin(ShowTest!("FormStatus"));

    assert("draft".toFormStatus == FormStatus.draft);
    assert("published".toFormStatus == FormStatus.published);
    assert("inactive".toFormStatus == FormStatus.inactive);
    assert("deprecated".toFormStatus == FormStatus.deprecated_);
    assert("archived".toFormStatus == FormStatus.archived);
    assert("error".toFormStatus == FormStatus.error);

    assert("".toFormStatus == FormStatus.draft);
    assert("some_unknown_status".toFormStatus == FormStatus.draft);

    assert(Formstatus.draft.toString == "draft");
    assert(FormStatus.published.toString == "published");
    assert(FormStatus.inactive.toString == "inactive");
    assert(FormStatus.deprecated_.toString == "deprecated");
    assert(FormStatus.archived.toString == "archived");
    assert(FormStatus.error.toString == "error");

    assert(["draft", "published", "inactive"].toFormStatuses == [
            FormStatus.draft, FormStatus.published, FormStatus.inactive
        ]);
    assert([FormStatus.draft, FormStatus.published, FormStatus.inactive].toStrings == [
            "draft", "published", "inactive"
        ]);
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
    mixin(EnumSwitch("FieldType", "text"));
}

FieldType[] toFieldTypes(string[] types)
    => types.map!toFieldType.array;

///
unittest {
    mixin(ShowTest!("FieldType"));

    assert("text".toFieldType == FieldType.text);
    assert("number".toFieldType == FieldType.number);
    assert("date".toFieldType == FieldType.date);
    assert("datetime".toFieldType == FieldType.datetime);
    assert("boolean".toFieldType == FieldType.boolean_);
    assert("dropdown".toFieldType == FieldType.dropdown);
    assert("radio".toFieldType == FieldType.radio);
    assert("checkbox".toFieldType == FieldType.checkbox);
    assert("textarea".toFieldType == FieldType.textarea);
    assert("fileUpload".toFieldType == FieldType.fileUpload);
    assert("table".toFieldType == FieldType.table);
    assert("paragraph".toFieldType == FieldType.paragraph);
    assert("headline".toFieldType == FieldType.headline);
    assert("link".toFieldType == FieldType.link);
    assert("image".toFieldType == FieldType.image);

    assert("".toFieldType.toString == "text");
    assert("unknown".toFieldType.toString == "text");

    assert(FieldType.text.toString == "text");
    assert(FieldType.number.toString == "number");
    assert(FieldType.date.toString == "date");
    assert(FieldType.datetime.toString == "datetime");
    assert(FieldType.boolean_.toString == "boolean");
    assert(FieldType.dropdown.toString == "dropdown");
    assert(FieldType.radio.toString == "radio");
    assert(FieldType.checkbox.toString == "checkbox");
    assert(FieldType.textarea.toString == "textarea");
    assert(FieldType.fileUpload.toString == "fileUpload");
    assert(FieldType.table.toString == "table");
    assert(FieldType.paragraph.toString == "paragraph");
    assert(FieldType.headline.toString == "headline");
    assert(FieldType.link.toString == "link");
    assert(FieldType.image.toString == "image");

    assert(["text", "number", "date"].toFieldTypes == [
            FieldType.text, FieldType.number, FieldType.date
        ]);

    assert([FieldType.text, FieldType.number, FieldType.date].toStrings == [
            "text", "number", "date"
        ]);
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
    mixin(EnumSwitch("AutomationStatus", "draft"));
}

AutomationStatus[] toAutomationStatuses(string[] statuses)
    => statuses.map!toAutomationStatus.array;

string toString(AutomationStatus status)
    => status.to!string;

string[] toStrings(AutomationStatus[] statuses)
    => statuses.map!toString.array;

///
unittest {
    mixin(ShowTest!("AutomationStatus"));

    assert("draft".toAutomationStatus == AutomationStatus.draft);
    assert("active".toAutomationStatus == AutomationStatus.active);
    assert("inactive".toAutomationStatus == AutomationStatus.inactive);
    assert("error".toAutomationStatus == AutomationStatus.error);

    assert("".toAutomationStatus == AutomationStatus.draft);
    assert("unknown".toAutomationStatus == AutomationStatus.draft);

    assert(AutomationStatus.draft.toString == "draft");
    assert(AutomationStatus.active.toString == "active");
    assert(AutomationStatus.inactive.toString == "inactive");
    assert(AutomationStatus.error.toString == "error");

    assert(["draft", "active", "inactive"].toAutomationStatuses == [
            AutomationStatus.draft, AutomationStatus.active,
            AutomationStatus.inactive
        ]);

    assert([
        AutomationStatus.draft, AutomationStatus.active, AutomationStatus.inactive
    ].toStrings == [
        "draft", "active", "inactive"
    ]);

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
    mixin(EnumSwitch("AutomationType", "attended"));
}

AutomationType[] toAutomationTypes(string[] types)
    => types.map!toAutomationType.array;

string toString(AutomationType type)
    => type.to!string;

string[] toStrings(AutomationType[] types)
    => types.map!toString.array;

///
unittest {
    mixin(ShowTest!("AutomationType"));

    assert("attended".toAutomationType == AutomationType.attended);
    assert("unattended".toAutomationType == AutomationType.unattended);
    assert("hybrid".toAutomationType == AutomationType.hybrid);
    assert("api".toAutomationType == AutomationType.api);

    assert("".toAutomationType == AutomationType.attended);
    assert("unknown".toAutomationType == AutomationType.attended);

    assert(AutomationType.attended.toString == "attended");
    assert(AutomationType.unattended.toString == "unattended");
    assert(AutomationType.hybrid.toString == "hybrid");
    assert(AutomationType.api.toString == "api");

    assert(["attended", "unattended", "hybrid"].toAutomationTypes == [
            AutomationType.attended, AutomationType.unattended,
            AutomationType.hybrid
        ]);
    assert([
        AutomationType.attended, AutomationType.unattended, AutomationType.hybrid
    ].toStrings == [
        "attended", "unattended", "hybrid"
    ]);
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
    mixin(EnumSwitch("AutomationRunStatus", "queued"));
}

AutomationRunStatus[] toAutomationRunStatuses(string[] statuses)
    => statuses.map!toAutomationRunStatus.array;

string toString(AutomationRunStatus status)
    => status.to!string;

string[] toStrings(AutomationRunStatus[] statuses)
    => statuses.map!toString.array;

///
unittest {
    mixin(ShowTest!("AutomationRunStatus"));

    assert("queued".toAutomationRunStatus == AutomationRunStatus.queued);
    assert("running".toAutomationRunStatus == AutomationRunStatus.running);
    assert("completed".toAutomationRunStatus == AutomationRunStatus.completed);
    assert("failed".toAutomationRunStatus == AutomationRunStatus.failed);
    assert("cancelled".toAutomationRunStatus == AutomationRunStatus.cancelled);
    assert("timedOut".toAutomationRunStatus == AutomationRunStatus.timedOut);

    assert("".toAutomationRunStatus == AutomationRunStatus.queued);
    assert("unknown".toAutomationRunStatus == AutomationRunStatus.queued);

    assert(AutomationRunStatus.queued.toString == "queued");
    assert(AutomationRunStatus.running.toString == "running");
    assert(AutomationRunStatus.completed.toString == "completed");
    assert(AutomationRunStatus.failed.toString == "failed");
    assert(AutomationRunStatus.cancelled.toString == "cancelled");
    assert(AutomationRunStatus.timedOut.toString == "timedOut");

    assert(["queued", "running", "completed"].toAutomationRunStatuses == [
            AutomationRunStatus.queued, AutomationRunStatus.running,
            AutomationRunStatus.completed
        ]);
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

TriggerType toTriggerType(string value) {
    mixin(EnumSwitch("TriggerType", "manual"));
}

TriggerType[] toTriggerTypes(string[] values)
    => values.map!toTriggerType.array;

string toString(TriggerType type)
    => type.to!string;

string[] toStrings(TriggerType[] types)
    => types.map!toString.array;

///
unittest {
    mixin(ShowTest!("TriggerType"));

    assert("manual".toTriggerType == TriggerType.manual);
    assert("scheduled".toTriggerType == TriggerType.scheduled);
    assert("api".toTriggerType == TriggerType.api);
    assert("event".toTriggerType == TriggerType.event);
    assert("email".toTriggerType == TriggerType.email);
    assert("webhook".toTriggerType == TriggerType.webhook);
    assert("formSubmission".toTriggerType == TriggerType.formSubmission);

    assert("".toTriggerType == TriggerType.manual);
    assert("unknown".toTriggerType == TriggerType.manual);

    assert(TriggerType.manual.toString == "manual");
    assert(TriggerType.scheduled.toString == "scheduled");
    assert(TriggerType.api.toString == "api");
    assert(TriggerType.event.toString == "event");
    assert(TriggerType.email.toString == "email");
    assert(TriggerType.webhook.toString == "webhook");
    assert(TriggerType.formSubmission.toString == "formSubmission");

    assert(["manual", "scheduled", "api"].toTriggerType == [
            TriggerType.manual, TriggerType.scheduled, TriggerType.api
        ]);
    assert([TriggerType.manual, TriggerType.scheduled, TriggerType.api].toStrings == [
            "manual", "scheduled", "api"
        ]);
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
    mixin(EnumSwitch("TriggerStatus", "active"));
}
TriggerStatus[] toTriggerStatuses(string[] statuses)
    => statuses.map!toTriggerStatus.array;

string toString(TriggerStatus status)
    => status.to!string;

string[] toStrings(TriggerStatus[] statuses)
    => statuses.map!toString.array;

///
unittest {
    mixin(ShowTest!("TriggerStatus"));

    assert("active".toTriggerStatus == TriggerStatus.active);
    assert("inactive".toTriggerStatus == TriggerStatus.inactive);
    assert("error".toTriggerStatus == TriggerStatus.error);

    assert("".toTriggerStatus == TriggerStatus.active);
    assert("unknown".toTriggerStatus == TriggerStatus.active);

    assert(TriggerStatus.active.toString == "active");
    assert(TriggerStatus.inactive.toString == "inactive");
    assert(TriggerStatus.error.toString == "error");

    assert(["active", "inactive", "error"].toTriggerStatuses == [
            TriggerStatus.active, TriggerStatus.inactive, TriggerStatus.error
        ]);
    assert([TriggerStatus.active, TriggerStatus.inactive, TriggerStatus.error].toStrings == ["active", "inactive", "error"]);
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
    mixin(EnumSwitch("ScheduleFrequency", "once"));
}

ScheduleFrequency[] toScheduleFrequencies(string[] freqs)
    => freqs.map!toScheduleFrequency.array;

string toString(ScheduleFrequency frequency) 
    => frequency.to!string;

string[] toStrings(ScheduleFrequency[] frequencies)
    => frequencies.map!toString.array;

///
unittest {
    mixin(ShowTest!("ScheduleFrequency"));

    assert("once".toScheduleFrequency == ScheduleFrequency.once);
    assert("minutely".toScheduleFrequency == ScheduleFrequency.minutely);
    assert("hourly".toScheduleFrequency == ScheduleFrequency.hourly);
    assert("daily".toScheduleFrequency == ScheduleFrequency.daily);
    assert("weekly".toScheduleFrequency == ScheduleFrequency.weekly);
    assert("monthly".toScheduleFrequency == ScheduleFrequency.monthly);
    assert("yearly".toScheduleFrequency == ScheduleFrequency.yearly);
    assert("cron".toScheduleFrequency == ScheduleFrequency.cron);

    assert("".toScheduleFrequency == ScheduleFrequency.once);
    assert("unknown".toScheduleFrequency == ScheduleFrequency.once);

    assert(ScheduleFrequency.once.toString == "once");
    assert(ScheduleFrequency.minutely.toString == "minutely");
    assert(ScheduleFrequency.hourly.toString == "hourly");
    assert(ScheduleFrequency.daily.toString == "daily");
    assert(ScheduleFrequency.weekly.toString == "weekly");
    assert(ScheduleFrequency.monthly.toString == "monthly");
    assert(ScheduleFrequency.yearly.toString == "yearly");
    assert(ScheduleFrequency.cron.toString == "cron");

    assert(["once", "hourly", "daily"].toScheduleFrequencies == [
            ScheduleFrequency.once, ScheduleFrequency.hourly, ScheduleFrequency.daily
        ]);
    assert([ScheduleFrequency.once, ScheduleFrequency.hourly, ScheduleFrequency.daily].toStrings
        == ["once", "hourly", "daily"]);
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
    mixin(EnumSwitch("ActionStatus", "draft"));
}

ActionStatus[] toActionStatuses(string[] statuses)
    => statuses.map!toActionStatus.array;

string toString(ActionStatus status)
    => status.to!string;

string[] toStrings(ActionStatus[] statuses)
    => statuses.map!toString.array;

/// 
unittest {
    mixin(EnumSwitch("ActionStatus", "draft"));

    assert(ActionStatus.draft.toString == "draft");
    assert(ActionStatus.active.toString == "active");
    assert(ActionStatus.inactive.toString == "inactive");
    assert(ActionStatus.error.toString == "error");

    assert("draft".toActionStatus == ActionStatus.draft);
    assert("active".toActionStatus == ActionStatus.active);
    assert("inactive".toActionStatus == ActionStatus.inactive);
    assert("error".toActionStatus == ActionStatus.error);

    assert("".toActionStatus == ActionStatus.draft);
    assert("unknown".toActionStatus == ActionStatus.draft);

    assert(["draft", "active", "inactive", "error"].toActionStatuses == [
            ActionStatus.draft, ActionStatus.active, ActionStatus.inactive,
            ActionStatus.error
        ]);
    assert([
        ActionStatus.draft, ActionStatus.active, ActionStatus.inactive,
        ActionStatus.error
    ].toStrings == ["draft", "active", "inactive", "error"]);
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
    mixin(EnumSwitch("ActionType", "custom"));
}

ActionType[] toActionTypes(string[] types)
    => types.map!toActionType.array;

string toString(ActionType type)
    => type.to!string;

string[] toStrings(ActionType[] types)
    => types.map!toString.array;

///
unittest {
    assert(ActionType.restApi.toString == "restApi");
    assert(ActionType.odata.toString == "odata");
    assert(ActionType.rfc.toString == "rfc");
    assert(ActionType.soap.toString == "soap");
    assert(ActionType.graphql.toString == "graphql");
    assert(ActionType.custom.toString == "custom");

    assert("rest_api".toActionType == ActionType.restApi);
    assert("odata".toActionType == ActionType.odata);
    assert("rfc".toActionType == ActionType.rfc);
    assert("soap".toActionType == ActionType.soap);
    assert("graphql".toActionType == ActionType.graphql);
    assert("custom".toActionType == ActionType.custom);

    assert("".toActionType == ActionType.custom);
    assert("unknown".toActionType == ActionType.custom);

    assert(["rest_api", "odata", "rfc", "soap", "graphql", "custom"].toActionTypes == [
            ActionType.restApi, ActionType.odata, ActionType.rfc,
            ActionType.soap, ActionType.graphql, ActionType.custom
        ]);
    assert([
        ActionType.restApi, ActionType.odata, ActionType.rfc, ActionType.soap,
        ActionType.graphql, ActionType.custom
    ].toStrings == ["restApi", "odata", "rfc", "soap", "graphql", "custom"]);

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
    mixin(EnumSwitch("VisibilityStatus", "active"));
}

VisibilityStatus[] toVisibilityStatuses(string[] statuses)
    => statuses.map!toVisibilityStatus.array;

string toString(VisibilityStatus status)
    => status.to!string;

string[] toStrings(VisibilityStatus[] statuses)
    => statuses.map!toString.array;

///
unittest {
    mixin(ShowTest!("VisibilityStatus"));

    assert("active".toVisibilityStatus == VisibilityStatus.active);
    assert("inactive".toVisibilityStatus == VisibilityStatus.inactive);
    assert("error".toVisibilityStatus == VisibilityStatus.error);

    assert("".toVisibilityStatus == VisibilityStatus.active);
    assert("unknown".toVisibilityStatus == VisibilityStatus.active);

    assert(VisibilityStatus.active.toString == "active");
    assert(VisibilityStatus.inactive.toString == "inactive");
    assert(VisibilityStatus.error.toString == "error");

    assert(["active", "inactive", "error"].toVisibilityStatuses == [
            VisibilityStatus.active, VisibilityStatus.inactive, VisibilityStatus.error
        ]);
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
    mixin(EnumSwitch("DashboardType", "custom"));
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

MetricType toMetricType(string value) {
    mixin(EnumSwitch("MetricType", "count"));
}
// --- Artifact Store ---

enum ArtifactType {
    // Artifact that represents a reusable process template, which may include predefined process models, configurations, and best practices that can be used to accelerate the design and implementation of new processes based on the process flow and requirements
    processTemplate,
    // Artifact that represents a reusable bot template, which may include predefined automation scripts, configurations, and best practices that can be used to accelerate the design and implementation of new automations based on the process flow and requirements
    botTemplate,
    // Artifact that represents a reusable form template , which may include predefined form designs, configurations, and best practices that can be used to accelerate the design and implementation of new forms based on the process flow and requirements
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
    mixin(EnumSwitch("ArtifactType", "processTemplate"));
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
    mixin(EnumSwitch("ArtifactStatus", "available"));
}
