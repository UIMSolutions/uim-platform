/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.enumerations;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

enum TaskStatus {
    open,
    inProgress,
    completed,
    cancelled,
    failed,
    forwarded,
    reserved
}
TaskStatus toTaskStatus(string value) {
    mixin(EnumSwitch("TaskStatus", "open"));
}
TaskStatus[] toTaskStatuses(string[] values) {
    return values.map!toTaskStatus.array;
}
string toString(TaskStatus value) {
    return value.to!string();
}
string[] toStrings(TaskStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("TaskStatus"));

    assert("open".toTaskStatus == TaskStatus.open);
    assert("inProgress".toTaskStatus == TaskStatus.inProgress);
    assert("completed".toTaskStatus == TaskStatus.completed);
    assert("cancelled".toTaskStatus == TaskStatus.cancelled);
    assert("failed".toTaskStatus == TaskStatus.failed);
    assert("forwarded".toTaskStatus == TaskStatus.forwarded);
    assert("reserved".toTaskStatus == TaskStatus.reserved);

    assert("".toTaskStatus == TaskStatus.open); // default value
    assert("unknown".toTaskStatus == TaskStatus.open); // default value

    assert(TaskStatus.open.toString == "open");
    assert(TaskStatus.inProgress.toString == "inProgress");
    assert(TaskStatus.completed.toString == "completed");
    assert(TaskStatus.cancelled.toString == "cancelled");
    assert(TaskStatus.failed.toString == "failed");
    assert(TaskStatus.forwarded.toString == "forwarded");
    assert(TaskStatus.reserved.toString == "reserved");

    assert(["open", "completed"].toTaskStatuses == [TaskStatus.open, TaskStatus.completed]);
    assert([TaskStatus.open, TaskStatus.completed].toStrings == ["open", "completed"]);
}

enum TaskPriority {
    low,
    medium,
    high,
    veryHigh
}
TaskPriority toTaskPriority(string value) {
    mixin(EnumSwitch("TaskPriority", "low"));
}
TaskPriority[] toTaskPriorities(string[] values) {
    return values.map!toTaskPriority.array;
}
string toString(TaskPriority value) {
    return value.to!string();
}
string[] toStrings(TaskPriority[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("TaskPriority"));

    assert("low".toTaskPriority == TaskPriority.low);
    assert("medium".toTaskPriority == TaskPriority.medium);
    assert("high".toTaskPriority == TaskPriority.high);
    assert("veryHigh".toTaskPriority == TaskPriority.veryHigh);

    assert("".toTaskPriority == TaskPriority.low); // default value
    assert("unknown".toTaskPriority == TaskPriority.low); // default value

    assert(TaskPriority.low.toString == "low");
    assert(TaskPriority.medium.toString == "medium");
    assert(TaskPriority.high.toString == "high");
    assert(TaskPriority.veryHigh.toString == "veryHigh");   

    assert(["low", "high"].toTaskPriorities == [TaskPriority.low, TaskPriority.high]);
    assert([TaskPriority.low, TaskPriority.high].toStrings == ["low", "high"]);
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
TaskCategory toTaskCategory(string value) {
    mixin(EnumSwitch("TaskCategory", "approval"));
}
TaskCategory[] toTaskCategories(string[] values) {
    return values.map!toTaskCategory.array;
}
string toString(TaskCategory value) {
    return value.to!string();
}
string[] toStrings(TaskCategory[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("TaskCategory"));

    assert("approval".toTaskCategory == TaskCategory.approval);
    assert("review".toTaskCategory == TaskCategory.review);
    assert("toDoItem".toTaskCategory == TaskCategory.toDoItem);
    assert("notification".toTaskCategory == TaskCategory.notification);
    assert("action".toTaskCategory == TaskCategory.action);
    assert("workflow".toTaskCategory == TaskCategory.workflow);
    assert("informational".toTaskCategory == TaskCategory.informational);

    assert("".toTaskCategory == TaskCategory.approval); // default value
    assert("unknown".toTaskCategory == TaskCategory.approval); // default value

    assert(TaskCategory.approval.toString == "approval");
    assert(TaskCategory.review.toString == "review");
    assert(TaskCategory.toDoItem.toString == "toDoItem");
    assert(TaskCategory.notification.toString == "notification");
    assert(TaskCategory.action.toString == "action");
    assert(TaskCategory.workflow.toString == "workflow");
    assert(TaskCategory.informational.toString == "informational");

    assert(["approval", "action"].toTaskCategories == [TaskCategory.approval, TaskCategory.action]);
    assert([TaskCategory.approval, TaskCategory.action].toStrings == ["approval", "action"]);
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
ProviderType toProviderType(string value) {
    mixin(EnumSwitch("ProviderType", "custom"));
}
ProviderType[] toProviderTypes(string[] values) {
    return values.map!toProviderType.array;
}
string toString(ProviderType value) {
    return value.to!string();
}
string[] toStrings(ProviderType[] values) {
    return values.map!toString.array;
}       
///
unittest {
    mixin(ShowTest!("ProviderType"));

    assert("s4hana".toProviderType == ProviderType.s4hana);
    assert("successFactors".toProviderType == ProviderType.successFactors);
    assert("ariba".toProviderType == ProviderType.ariba);
    assert("fieldglass".toProviderType == ProviderType.fieldglass);
    assert("concur".toProviderType == ProviderType.concur);
    assert("sapBuild".toProviderType == ProviderType.sapBuild);
    assert("custom".toProviderType == ProviderType.custom); 

    assert("".toProviderType == ProviderType.custom); // default value
    assert("unknown".toProviderType == ProviderType.custom); // default value

    assert(ProviderType.s4hana.toString == "s4hana");
    assert(ProviderType.successFactors.toString == "successFactors");
    assert(ProviderType.ariba.toString == "ariba");
    assert(ProviderType.fieldglass.toString == "fieldglass");
    assert(ProviderType.concur.toString == "concur");
    assert(ProviderType.sapBuild.toString == "sapBuild");
    assert(ProviderType.custom.toString == "custom");   

    assert(["s4hana", "ariba"].toProviderTypes == [ProviderType.s4hana, ProviderType.ariba]);
    assert([ProviderType.s4hana, ProviderType.ariba].toStrings == ["s4hana", "ariba"]);
}

enum ProviderStatus {
    active,
    inactive,
    error,
    syncing
}
ProviderStatus toProviderStatus(string value) {
    mixin(EnumSwitch("ProviderStatus", "active"));
}
ProviderStatus[] toProviderStatuses(string[] values) {
    return values.map!toProviderStatus.array;
}
string toString(ProviderStatus value) {
    return value.to!string();
}
string[] toStrings(ProviderStatus[] values) {
    return values.map!toString.array;
}   
///
unittest {
    mixin(ShowTest!("ProviderStatus"));

    assert("active".toProviderStatus == ProviderStatus.active);
    assert("inactive".toProviderStatus == ProviderStatus.inactive);
    assert("error".toProviderStatus == ProviderStatus.error);
    assert("syncing".toProviderStatus == ProviderStatus.syncing); 

    assert("".toProviderStatus == ProviderStatus.active); // default value
    assert("unknown".toProviderStatus == ProviderStatus.active); // default value

    assert(ProviderStatus.active.toString == "active");
    assert(ProviderStatus.inactive.toString == "inactive");
    assert(ProviderStatus.error.toString == "error");
    assert(ProviderStatus.syncing.toString == "syncing");   

    assert(["active", "error"].toProviderStatuses == [ProviderStatus.active, ProviderStatus.error]);
    assert([ProviderStatus.active, ProviderStatus.error].toStrings == ["active", "error"]);
}

enum AuthenticationType {
    oauth2,
    basicAuth,
    certificate,
    apiKey,
    saml
}
AuthenticationType toAuthenticationType(string value) {
    mixin(EnumSwitch("AuthenticationType", "oauth2"));
}
AuthenticationType[] toAuthenticationTypes(string[] values) {
    return values.map!toAuthenticationType.array;
}
string toString(AuthenticationType value) {
    return value.to!string();
}
string[] toStrings(AuthenticationType[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("AuthenticationType"));

    assert("oauth2".toAuthenticationType == AuthenticationType.oauth2);
    assert("basicAuth".toAuthenticationType == AuthenticationType.basicAuth);
    assert("certificate".toAuthenticationType == AuthenticationType.certificate);
    assert("apiKey".toAuthenticationType == AuthenticationType.apiKey);
    assert("saml".toAuthenticationType == AuthenticationType.saml);

    assert("".toAuthenticationType == AuthenticationType.oauth2); // default value
    assert("unknown".toAuthenticationType == AuthenticationType.oauth2); // default value

    assert(AuthenticationType.oauth2.toString == "oauth2");
    assert(AuthenticationType.basicAuth.toString == "basicAuth");
    assert(AuthenticationType.certificate.toString == "certificate");
    assert(AuthenticationType.apiKey.toString == "apiKey");
    assert(AuthenticationType.saml.toString == "saml");

    assert(["oauth2", "apiKey"].toAuthenticationTypes == [AuthenticationType.oauth2, AuthenticationType.apiKey]);
    assert([AuthenticationType.oauth2, AuthenticationType.apiKey].toStrings == ["oauth2", "apiKey"]);
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
ActionType toActionType(string value) {
    mixin(EnumSwitch("ActionType", "approve"));
}
ActionType[] toActionTypes(string[] values) {
    return values.map!toActionType.array;
}
string toString(ActionType value) {
    return value.to!string();
}
string[] toStrings(ActionType[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("ActionType"));

    assert("approve".toActionType == ActionType.approve);
    assert("reject".toActionType == ActionType.reject);
    assert("forward".toActionType == ActionType.forward);
    assert("claim".toActionType == ActionType.claim);
    assert("release".toActionType == ActionType.release);
    assert("escalate".toActionType == ActionType.escalate);
    assert("complete".toActionType == ActionType.complete);
    assert("cancel".toActionType == ActionType.cancel);
    assert("resubmit".toActionType == ActionType.resubmit);

    assert("".toActionType == ActionType.approve); // default value
    assert("unknown".toActionType == ActionType.approve); // default value

    assert(ActionType.approve.toString == "approve");
    assert(ActionType.reject.toString == "reject");
    assert(ActionType.forward.toString == "forward");
    assert(ActionType.claim.toString == "claim");
    assert(ActionType.release.toString == "release");
    assert(ActionType.escalate.toString == "escalate");
    assert(ActionType.complete.toString == "complete");
    assert(ActionType.cancel.toString == "cancel");
    assert(ActionType.resubmit.toString == "resubmit");

    assert(["approve", "reject"].toActionTypes == [ActionType.approve, ActionType.reject]);
    assert([ActionType.approve, ActionType.reject].toStrings == ["approve", "reject"]);
}

enum SubstitutionStatus {
    active,
    inactive,
    expired,
    pending
}
SubstitutionStatus toSubstitutionStatus(string value) {
    mixin(EnumSwitch("SubstitutionStatus", "active"));
}
SubstitutionStatus[] toSubstitutionStatuses(string[] values) {
    return values.map!toSubstitutionStatus.array;
}
string toString(SubstitutionStatus value) {
    return value.to!string();
}
string[] toStrings(SubstitutionStatus[] values) {
    return values.map!toString.array;
}
///
unittest {  
    mixin(ShowTest!("SubstitutionStatus"));

    assert("active".toSubstitutionStatus == SubstitutionStatus.active);
    assert("inactive".toSubstitutionStatus == SubstitutionStatus.inactive);
    assert("expired".toSubstitutionStatus == SubstitutionStatus.expired);
    assert("pending".toSubstitutionStatus == SubstitutionStatus.pending);

    assert("".toSubstitutionStatus == SubstitutionStatus.active); // default value
    assert("unknown".toSubstitutionStatus == SubstitutionStatus.active); // default value

    assert(SubstitutionStatus.active.toString == "active");
    assert(SubstitutionStatus.inactive.toString == "inactive");
    assert(SubstitutionStatus.expired.toString == "expired");
    assert(SubstitutionStatus.pending.toString == "pending");

    assert(["active", "expired"].toSubstitutionStatuses == [SubstitutionStatus.active, SubstitutionStatus.expired]);
    assert([SubstitutionStatus.active, SubstitutionStatus.expired].toStrings == ["active", "expired"]);
}


enum AttachmentStatus {
    uploaded,
    processing,
    available,
    deleted
}
AttachmentStatus toAttachmentStatus(string value) {
    mixin(EnumSwitch("AttachmentStatus", "uploaded"));
}
AttachmentStatus[] toAttachmentStatuses(string[] values) {
    return values.map!toAttachmentStatus.array;
}
string toString(AttachmentStatus value) {
    return value.to!string();
}
string[] toStrings(AttachmentStatus[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("AttachmentStatus"));

    assert("uploaded".toAttachmentStatus == AttachmentStatus.uploaded);
    assert("processing".toAttachmentStatus == AttachmentStatus.processing);
    assert("available".toAttachmentStatus == AttachmentStatus.available);
    assert("deleted".toAttachmentStatus == AttachmentStatus.deleted);   

    assert("".toAttachmentStatus == AttachmentStatus.uploaded); // default value
    assert("unknown".toAttachmentStatus == AttachmentStatus.uploaded); // default value

    assert(AttachmentStatus.uploaded.toString == "uploaded");
    assert(AttachmentStatus.processing.toString == "processing");
    assert(AttachmentStatus.available.toString == "available");
    assert(AttachmentStatus.deleted.toString == "deleted");

    assert(["uploaded", "available"].toAttachmentStatuses == [AttachmentStatus.uploaded, AttachmentStatus.available]);
    assert([AttachmentStatus.uploaded, AttachmentStatus.available].toStrings == ["uploaded", "available"]);
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
FilterCriterionType toFilterCriterionType(string value) {
    mixin(EnumSwitch("FilterCriterionType", "status"));
}   
FilterCriterionType[] toFilterCriterionTypes(string[] values) {
    return values.map!toFilterCriterionType.array;
}
string toString(FilterCriterionType value) {
    return value.to!string();
}
string[] toStrings(FilterCriterionType[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("FilterCriterionType"));    

    assert("status".toFilterCriterionType == FilterCriterionType.status);
    assert("priority".toFilterCriterionType == FilterCriterionType.priority);
    assert("provider".toFilterCriterionType == FilterCriterionType.provider);
    assert("category".toFilterCriterionType == FilterCriterionType.category);
    assert("dueDate".toFilterCriterionType == FilterCriterionType.dueDate);
    assert("assignee".toFilterCriterionType == FilterCriterionType.assignee);
    assert("creator".toFilterCriterionType == FilterCriterionType.creator); 
    assert("taskDefinition".toFilterCriterionType == FilterCriterionType.taskDefinition);   

    assert("".toFilterCriterionType == FilterCriterionType.status); // default value
    assert("unknown".toFilterCriterionType == FilterCriterionType.status); // default value

    assert(FilterCriterionType.status.toString == "status");
    assert(FilterCriterionType.priority.toString == "priority");
    assert(FilterCriterionType.provider.toString == "provider");
    assert(FilterCriterionType.category.toString == "category");
    assert(FilterCriterionType.dueDate.toString == "dueDate");
    assert(FilterCriterionType.assignee.toString == "assignee");    
    assert(FilterCriterionType.creator.toString == "creator");
    assert(FilterCriterionType.taskDefinition.toString == "taskDefinition");    

    assert(["status", "priority"].toFilterCriterionTypes == [FilterCriterionType.status, FilterCriterionType.priority]);
    assert([FilterCriterionType.status, FilterCriterionType.priority].toStrings == ["status", "priority"]);
}

