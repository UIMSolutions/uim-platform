/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.container;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct Container {
    ManageTasksUseCase manageTasksUseCase;
    ManageTaskDefinitionsUseCase manageTaskDefinitionsUseCase;
    ManageTaskCommentsUseCase manageTaskCommentsUseCase;
    ManageTaskAttachmentsUseCase manageTaskAttachmentsUseCase;
    ManageTaskProvidersUseCase manageTaskProvidersUseCase;
    ManageSubstitutionRulesUseCase manageSubstitutionRulesUseCase;
    ManageTaskActionsUseCase manageTaskActionsUseCase;
    ManageUserTaskFiltersUseCase manageUserTaskFiltersUseCase;

    TaskController taskController;
    TaskDefinitionController definitionController;
    TaskCommentController commentController;
    TaskAttachmentController attachmentController;
    TaskProviderController providerController;
    SubstitutionRuleController substitutionController;
    TaskActionController actionController;
    UserTaskFilterController filterController;
    HealthController healthController;
}

Container buildContainer(AppConfig config) {
    Container c;

    // Repositories
    auto taskRepo = new MemoryTaskRepository();
    auto defRepo = new MemoryTaskDefinitionRepository();
    auto commentRepo = new MemoryTaskCommentRepository();
    auto attachRepo = new MemoryTaskAttachmentRepository();
    auto providerRepo = new MemoryTaskProviderRepository();
    auto subRepo = new MemorySubstitutionRuleRepository();
    auto actionRepo = new MemoryTaskActionRepository();
    auto filterRepo = new MemoryUserTaskFilterRepository();

    // Use Cases
    c.manageTasksUseCase = new ManageTasksUseCase(taskRepo);
    c.manageTaskDefinitionsUseCase = new ManageTaskDefinitionsUseCase(defRepo);
    c.manageTaskCommentsUseCase = new ManageTaskCommentsUseCase(commentRepo);
    c.manageTaskAttachmentsUseCase = new ManageTaskAttachmentsUseCase(attachRepo);
    c.manageTaskProvidersUseCase = new ManageTaskProvidersUseCase(providerRepo);
    c.manageSubstitutionRulesUseCase = new ManageSubstitutionRulesUseCase(subRepo);
    c.manageTaskActionsUseCase = new ManageTaskActionsUseCase(actionRepo);
    c.manageUserTaskFiltersUseCase = new ManageUserTaskFiltersUseCase(filterRepo);

    // Controllers
    c.taskController = new TaskController(c.manageTasksUseCase);
    c.definitionController = new TaskDefinitionController(c.manageTaskDefinitionsUseCase);
    c.commentController = new TaskCommentController(c.manageTaskCommentsUseCase);
    c.attachmentController = new TaskAttachmentController(c.manageTaskAttachmentsUseCase);
    c.providerController = new TaskProviderController(c.manageTaskProvidersUseCase);
    c.substitutionController = new SubstitutionRuleController(c.manageSubstitutionRulesUseCase);
    c.actionController = new TaskActionController(c.manageTaskActionsUseCase);
    c.filterController = new UserTaskFilterController(c.manageUserTaskFiltersUseCase);
    c.healthController = new HealthController("Task Center Service");

    return c;
}
