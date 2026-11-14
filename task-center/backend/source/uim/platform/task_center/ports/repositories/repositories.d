/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the aggregates.
module uim.platform.task_center.ports.repositories.repositories;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface ITaskRepository : IEntityRepository!(UIMTask, TaskId) {
  UIMTask[] findByProvider(TenantId t, TaskProviderId providerId);
  UIMTask[] findByDefinition(TenantId t, TaskDefinitionId definitionId);
  UIMTask[] findByAssignee(TenantId t, string assignee);
  /// The task federated from a provider under its external id.
  UIMTask findByExternalId(TenantId t, TaskProviderId providerId, string externalTaskId);
}

interface ITaskDefinitionRepository : IEntityRepository!(TaskDefinition, TaskDefinitionId) {
  TaskDefinition findByName(TenantId t, string name);
  TaskDefinition[] findByProvider(TenantId t, TaskProviderId providerId);
}

interface ITaskProviderRepository : IEntityRepository!(TaskProvider, TaskProviderId) {
  TaskProvider findByName(TenantId t, string name);
}

interface ITaskCommentRepository : IEntityRepository!(TaskComment, TaskCommentId) {
  TaskComment[] findByTask(TenantId t, TaskId taskId);
}

interface ITaskAttachmentRepository : IEntityRepository!(TaskAttachment, TaskAttachmentId) {
  TaskAttachment[] findByTask(TenantId t, TaskId taskId);
}

interface ITaskActionRepository : IEntityRepository!(TaskAction, TaskActionId) {
  /// Actions of a task, oldest first.
  TaskAction[] findByTask(TenantId t, TaskId taskId);
}

interface ISubstitutionRuleRepository : IEntityRepository!(SubstitutionRule, SubstitutionRuleId) {
  SubstitutionRule[] findByUser(TenantId t, string userId);
}

interface IUserTaskFilterRepository : IEntityRepository!(UserTaskFilter, UserTaskFilterId) {
  UserTaskFilter[] findByUser(TenantId t, string userId);
}
