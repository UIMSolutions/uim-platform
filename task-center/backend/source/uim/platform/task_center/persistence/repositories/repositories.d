/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (driven port implementations).
module uim.platform.task_center.persistence.repositories.repositories;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskRepository : DocumentRepository!(UIMTask, TaskId, taskToRecord, recordToTask), ITaskRepository {
  this(IDocumentStore store) {
    super(store, Collections.tasks);
  }

  UIMTask[] findByProvider(TenantId t, TaskProviderId providerId) {
    return where(t, (const UIMTask e) => e.providerId == providerId);
  }

  UIMTask[] findByDefinition(TenantId t, TaskDefinitionId definitionId) {
    return where(t, (const UIMTask e) => e.definitionId == definitionId);
  }

  UIMTask[] findByAssignee(TenantId t, string assignee) {
    return where(t, (const UIMTask e) => e.assignee == assignee);
  }

  UIMTask findByExternalId(TenantId t, TaskProviderId providerId, string externalTaskId) {
    if (externalTaskId.length == 0)
      return UIMTask.init;
    return first(t, (const UIMTask e) => e.providerId == providerId && e.externalTaskId == externalTaskId);
  }
}

class TaskDefinitionRepository : DocumentRepository!(TaskDefinition, TaskDefinitionId, definitionToRecord, recordToDefinition),
ITaskDefinitionRepository {
  this(IDocumentStore store) {
    super(store, Collections.definitions);
  }

  TaskDefinition findByName(TenantId t, string name) {
    return first(t, (const TaskDefinition e) => e.name == name);
  }

  TaskDefinition[] findByProvider(TenantId t, TaskProviderId providerId) {
    return where(t, (const TaskDefinition e) => e.providerId == providerId);
  }
}

class TaskProviderRepository : DocumentRepository!(TaskProvider, TaskProviderId, providerToRecord, recordToProvider),
ITaskProviderRepository {
  this(IDocumentStore store) {
    super(store, Collections.providers);
  }

  TaskProvider findByName(TenantId t, string name) {
    return first(t, (const TaskProvider e) => e.name == name);
  }
}

class TaskCommentRepository : DocumentRepository!(TaskComment, TaskCommentId, commentToRecord, recordToComment),
ITaskCommentRepository {
  this(IDocumentStore store) {
    super(store, Collections.comments);
  }

  TaskComment[] findByTask(TenantId t, TaskId taskId) {
    return where(t, (const TaskComment e) => e.taskId == taskId);
  }
}

class TaskAttachmentRepository : DocumentRepository!(TaskAttachment, TaskAttachmentId, attachmentToRecord, recordToAttachment),
ITaskAttachmentRepository {
  this(IDocumentStore store) {
    super(store, Collections.attachments);
  }

  TaskAttachment[] findByTask(TenantId t, TaskId taskId) {
    return where(t, (const TaskAttachment e) => e.taskId == taskId);
  }
}

class TaskActionRepository : DocumentRepository!(TaskAction, TaskActionId, actionToRecord, recordToAction),
ITaskActionRepository {
  this(IDocumentStore store) {
    super(store, Collections.actions);
  }

  TaskAction[] findByTask(TenantId t, TaskId taskId) {
    return where(t, (const TaskAction e) => e.taskId == taskId);
  }
}

class SubstitutionRuleRepository : DocumentRepository!(SubstitutionRule, SubstitutionRuleId, substitutionToRecord,
  recordToSubstitution), ISubstitutionRuleRepository {
  this(IDocumentStore store) {
    super(store, Collections.substitutions);
  }

  SubstitutionRule[] findByUser(TenantId t, string userId) {
    return where(t, (const SubstitutionRule e) => e.userId == userId);
  }
}

class UserTaskFilterRepository : DocumentRepository!(UserTaskFilter, UserTaskFilterId, filterToRecord, recordToFilter),
IUserTaskFilterRepository {
  this(IDocumentStore store) {
    super(store, Collections.filters);
  }

  UserTaskFilter[] findByUser(TenantId t, string userId) {
    return where(t, (const UserTaskFilter e) => e.userId == userId);
  }
}

///
unittest {
  auto store = new MemoryDocumentStore;
  auto repo = new TaskRepository(store);
  UIMTask a, b;
  a.id = TaskId("a");
  a.tenantId = TenantId("t1");
  a.title = "A";
  a.providerId = TaskProviderId("p");
  a.externalTaskId = "X-1";
  a.createdAt = 1;
  b = a;
  b.id = TaskId("b");
  b.externalTaskId = "X-2";
  b.createdAt = 2;
  repo.save(a);
  repo.save(b);
  assert(repo.findAll(TenantId("t1")).map!(e => e.id.value).array == ["a", "b"]);
  assert(repo.findByExternalId(TenantId("t1"), TaskProviderId("p"), "X-2").id.value == "b");
  assert(repo.findByExternalId(TenantId("t1"), TaskProviderId("q"), "X-2").isNull);
  assert(repo.findAll(TenantId("t2")).length == 0);
  assert(repo.removeById(TenantId("t1"), TaskId("a")) && !repo.existsById(TenantId("t1"), TaskId("a")));
}
