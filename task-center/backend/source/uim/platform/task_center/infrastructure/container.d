/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.task_center.infrastructure.container;

import uim.platform.task_center;
import uim.platform.task_center.presentation.odata.engine : taskCenterEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class TaskCenterContainer {
  TaskCenterConfig config;
  IDocumentStore store;
  ITaskProviderGateway gateway;
  ITaskEventPublisher events;
  TaskCenterPorts ports;
  ODataEngine engine; /// drives OData, REST, CLI and GUI

  /// gateway / store / events may be injected (tests); defaults follow the configuration.
  this(TaskCenterConfig config, ITaskProviderGateway gateway = null, IDocumentStore store = null,
    ITaskEventPublisher events = null) {
    this.config = config;
    this.store = store !is null ? store : createDocumentStore(config.storage, config.dataFile);
    this.gateway = gateway !is null ? gateway : new HttpTaskProviderClient(config.providerTimeoutSeconds);
    this.events = events !is null ? events : new LoggingTaskEventPublisher;

    // driven adapters
    auto tasks = new TaskRepository(this.store);
    auto definitions = new TaskDefinitionRepository(this.store);
    auto providers = new TaskProviderRepository(this.store);
    auto comments = new TaskCommentRepository(this.store);
    auto attachments = new TaskAttachmentRepository(this.store);
    auto actions = new TaskActionRepository(this.store);
    auto substitutions = new SubstitutionRuleRepository(this.store);
    auto filters = new UserTaskFilterRepository(this.store);

    // application
    ports.tasks = new ManageTasksUseCase(tasks, definitions, providers, substitutions, comments, attachments, actions, this.events);
    ports.processing = new ProcessTasksUseCase(tasks, definitions, substitutions, actions, comments, this.events);
    ports.definitions = new ManageTaskDefinitionsUseCase(definitions, providers, tasks);
    ports.providers = new ManageTaskProvidersUseCase(providers, definitions, tasks);
    ports.sync = new SyncTaskProvidersUseCase(providers, definitions, tasks, ports.tasks, this.gateway, this.events);
    ports.comments = new ManageTaskCommentsUseCase(comments, tasks, this.events);
    ports.attachments = new ManageTaskAttachmentsUseCase(attachments, tasks);
    ports.substitutions = new ManageSubstitutionRulesUseCase(substitutions, definitions);
    ports.filters = new ManageUserTaskFiltersUseCase(filters);
    ports.statistics = new TaskCenterStatisticsService(tasks, providers, definitions, substitutions, comments, attachments, actions);

    // one engine for all driving adapters
    engine = taskCenterEngine(ports, config.maxPageSize);
  }
}
