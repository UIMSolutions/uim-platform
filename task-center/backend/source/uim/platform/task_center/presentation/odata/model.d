/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the REST
/// adapter, the CLI and the GtkD GUI.
///
/// Scopes: Read (all reads), Process (task actions, comments, attachments,
/// own substitution rules and filters), Manage (providers, definitions,
/// creating/changing/deleting tasks, provider sync, others' personal data).
module uim.platform.task_center.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.task_center;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.taskcenter";

ODataServiceModel taskCenterModel() {
  auto m = new ODataServiceModel(odataNamespace, "TaskCenterService", "Task Center");

  m.entitySet("Tasks", "Task")
    .tenantAware()
    .property("title", Edm.string_, "Title", false)
    .property("description", Edm.string_, "Description")
    .property("status", Edm.string_, "Status")
    .property("priority", Edm.string_, "Priority")
    .property("category", Edm.string_, "Category")
    .property("outcome", Edm.string_, "Outcome")
    .property("definitionId", Edm.string_, "Task Definition")
    .property("providerId", Edm.string_, "Provider")
    .property("externalTaskId", Edm.string_, "External ID")
    .property("assignee", Edm.string_, "Assignee")
    .property("substitutedFor", Edm.string_, "Substituted For")
    .property("creator", Edm.string_, "Creator")
    .property("processor", Edm.string_, "Processor")
    .property("sourceApplication", Edm.string_, "Source Application")
    .collection("allowedActions", Edm.string_, "Allowed Actions")
    .collection("availableActions", Edm.string_, "Available Actions")
    .property("customAttributes", Edm.string_, "Custom Attributes (JSON)")
    .property("isClaimed", Edm.boolean, "Claimed")
    .property("claimedBy", Edm.string_, "Claimed By")
    .property("dueDate", Edm.date, "Due Date")
    .property("isOverdue", Edm.boolean, "Overdue")
    .property("completedAt", Edm.dateTimeOffset, "Completed At")
    .property("commentCount", Edm.int32, "Comments")
    .property("attachmentCount", Edm.int32, "Attachments")
    .computed("status", "outcome", "substitutedFor", "processor", "availableActions", "isClaimed", "claimedBy",
      "isOverdue", "completedAt", "commentCount", "attachmentCount")
    .immutableProps("definitionId", "providerId", "externalTaskId", "creator")
    .writable()
    .titled("Task", "Tasks", "title", "description")
    .columns("title", "status", "priority", "assignee", "dueDate", "sourceApplication")
    .filters("status", "priority", "category", "assignee", "providerId", "definitionId")
    .scopes("Read", "Manage");

  m.entitySet("TaskDefinitions", "TaskDefinition")
    .tenantAware()
    .property("providerId", Edm.string_, "Provider")
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("category", Edm.string_, "Category")
    .property("defaultPriority", Edm.string_, "Default Priority")
    .collection("allowedActions", Edm.string_, "Allowed Actions")
    .property("taskSchema", Edm.string_, "Task Schema (JSON)")
    .property("dueInDays", Edm.int32, "Due In (days)")
    .property("isActive", Edm.boolean, "Active")
    .property("requiresClaim", Edm.boolean, "Requires Claim")
    .property("taskCount", Edm.int32, "Tasks")
    .property("openTaskCount", Edm.int32, "Unfinished Tasks")
    .computed("taskCount", "openTaskCount")
    .immutableProps("providerId")
    .writable()
    .titled("Task Definition", "Task Definitions", "name", "description")
    .columns("name", "category", "defaultPriority", "dueInDays", "isActive", "openTaskCount")
    .filters("providerId", "category", "isActive")
    .scopes("Read", "Manage");

  m.entitySet("TaskProviders", "TaskProvider")
    .tenantAware()
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("providerType", Edm.string_, "Provider Type")
    .property("status", Edm.string_, "Status")
    .property("authType", Edm.string_, "Authentication")
    .property("endpointUrl", Edm.string_, "Task Endpoint")
    .property("authEndpointUrl", Edm.string_, "Token Endpoint")
    .property("clientId", Edm.string_, "Client ID / User")
    .property("clientSecret", Edm.string_, "Client Secret / Password")
    .property("hasSecret", Edm.boolean, "Has Secret")
    .property("lastSyncAt", Edm.dateTimeOffset, "Last Sync")
    .property("lastSyncError", Edm.string_, "Last Sync Error")
    .property("taskCount", Edm.int32, "Tasks")
    .property("definitionCount", Edm.int32, "Definitions")
    .computed("hasSecret", "lastSyncAt", "lastSyncError", "taskCount", "definitionCount")
    .writable()
    .titled("Task Provider", "Task Providers", "name", "providerType")
    .columns("name", "providerType", "status", "lastSyncAt", "taskCount", "definitionCount")
    .filters("providerType", "status", "authType")
    .scopes("Read", "Manage");

  m.entitySet("TaskComments", "TaskComment")
    .tenantAware()
    .property("taskId", Edm.string_, "Task", false)
    .property("author", Edm.string_, "Author")
    .property("content", Edm.string_, "Comment", false)
    .computed("author")
    .immutableProps("taskId")
    .writable()
    .titled("Comment", "Comments", "content", "author")
    .columns("taskId", "author", "content", "createdAt")
    .filters("taskId", "author")
    .scopes("Read", "Process");

  m.entitySet("TaskAttachments", "TaskAttachment")
    .tenantAware()
    .property("taskId", Edm.string_, "Task", false)
    .property("fileName", Edm.string_, "File Name", false)
    .property("fileSize", Edm.int64, "Size (bytes)")
    .property("mimeType", Edm.string_, "MIME Type")
    .property("url", Edm.string_, "Download URL")
    .property("status", Edm.string_, "Status")
    .property("uploadedBy", Edm.string_, "Uploaded By")
    .computed("uploadedBy")
    .immutableProps("taskId", "fileSize")
    .writable()
    .titled("Attachment", "Attachments", "fileName", "mimeType")
    .columns("fileName", "mimeType", "fileSize", "uploadedBy", "status")
    .filters("taskId", "status")
    .scopes("Read", "Process");

  m.entitySet("TaskActions", "TaskAction")
    .tenantAware()
    .property("taskId", Edm.string_, "Task")
    .property("actionType", Edm.string_, "Action")
    .property("performedBy", Edm.string_, "Performed By")
    .property("performedAt", Edm.dateTimeOffset, "Performed At")
    .property("forwardTo", Edm.string_, "Forwarded To")
    .property("comment", Edm.string_, "Comment")
    .property("fromStatus", Edm.string_, "From Status")
    .property("toStatus", Edm.string_, "To Status")
    .computed("taskId", "actionType", "performedBy", "performedAt", "forwardTo", "comment", "fromStatus", "toStatus")
    .writable(false, false, false) // audit trail: written by PerformTaskAction only
    .titled("Task Action", "Task Actions", "actionType", "performedBy")
    .columns("performedAt", "taskId", "actionType", "performedBy", "fromStatus", "toStatus")
    .filters("taskId", "actionType", "performedBy")
    .scopes("Read", "");

  m.entitySet("SubstitutionRules", "SubstitutionRule")
    .tenantAware()
    .property("userId", Edm.string_, "User")
    .property("substituteId", Edm.string_, "Substitute", false)
    .property("definitionId", Edm.string_, "Task Definition")
    .property("status", Edm.string_, "Status")
    .property("effectiveStatus", Edm.string_, "Effective Status")
    .property("startDate", Edm.date, "Start Date")
    .property("endDate", Edm.date, "End Date")
    .property("isAutoForward", Edm.boolean, "Auto-Forward")
    .computed("effectiveStatus")
    .immutableProps("userId")
    .writable()
    .titled("Substitution Rule", "Substitution Rules", "substituteId", "userId")
    .columns("userId", "substituteId", "startDate", "endDate", "isAutoForward", "effectiveStatus")
    .filters("userId", "substituteId", "status")
    .scopes("Read", "Process");

  m.entitySet("UserTaskFilters", "UserTaskFilter")
    .tenantAware()
    .property("userId", Edm.string_, "User")
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("criteria", Edm.string_, "Criteria (type=value, …)")
    .property("isDefault", Edm.boolean, "Default")
    .property("odataFilter", Edm.string_, "OData $filter")
    .computed("odataFilter")
    .immutableProps("userId")
    .writable()
    .titled("Filter", "Filters", "name", "criteria")
    .columns("name", "userId", "criteria", "isDefault")
    .filters("userId", "isDefault")
    .scopes("Read", "Process");

  m.singletonSet("Statistics", "Statistic")
    .property("tenantId", Edm.string_, "Tenant")
    .property("tasks", Edm.int32, "Tasks")
    .property("openTasks", Edm.int32, "Open")
    .property("inProgressTasks", Edm.int32, "In Progress")
    .property("completedTasks", Edm.int32, "Completed")
    .property("cancelledTasks", Edm.int32, "Cancelled")
    .property("failedTasks", Edm.int32, "Failed")
    .property("overdueTasks", Edm.int32, "Overdue")
    .property("highPriorityTasks", Edm.int32, "High Priority")
    .property("unassignedTasks", Edm.int32, "Unassigned")
    .property("approvedTasks", Edm.int32, "Approved")
    .property("rejectedTasks", Edm.int32, "Rejected")
    .property("providers", Edm.int32, "Providers")
    .property("activeProviders", Edm.int32, "Active Providers")
    .property("providersInError", Edm.int32, "Providers in Error")
    .property("definitions", Edm.int32, "Task Definitions")
    .property("activeSubstitutions", Edm.int32, "Active Substitutions")
    .property("comments", Edm.int32, "Comments")
    .property("attachments", Edm.int32, "Attachments")
    .property("actions", Edm.int32, "Actions")
    .titled("Statistics", "Statistics")
    .scopes("Read", "");

  m.complexType("SyncResult")
    .property("providerId", Edm.string_, "Provider")
    .property("providerName", Edm.string_, "Name")
    .property("fetched", Edm.int32, "Fetched")
    .property("created", Edm.int32, "Created")
    .property("updated", Edm.int32, "Updated")
    .property("skipped", Edm.int32, "Skipped")
    .property("error", Edm.string_, "Error")
    .property("syncedAt", Edm.dateTimeOffset, "Synced At");

  m.action("PerformTaskAction", "Task")
    .parameter("taskId", Edm.string_, false)
    .parameter("action", Edm.string_, false)
    .parameter("forwardTo", Edm.string_)
    .parameter("comment", Edm.string_)
    .labelled("Perform Task Action")
    .requires("Process");

  m.action("SyncProvider", "SyncResult")
    .parameter("providerId", Edm.string_, false)
    .labelled("Sync Provider")
    .requires("Manage");

  auto all = m.action("SyncAllProviders", "SyncResult")
    .labelled("Sync All Providers")
    .requires("Manage");
  all.returnsCollection = true;

  m.validate();
  return m;
}

///
unittest {
  auto m = taskCenterModel();
  assert(m.has("Tasks") && m.find("Statistics").singleton);
  assert(m.findAction("PerformTaskAction").returnEdmType == "uim.taskcenter.Task");
  assert(m.findAction("SyncAllProviders").returnEdmType == "Collection(uim.taskcenter.SyncResult)");
  assert(!m.find("TaskActions").insertable && !m.find("TaskActions").deletable);
  assert(m.find("Tasks").propertyOf("status").computed);
}
