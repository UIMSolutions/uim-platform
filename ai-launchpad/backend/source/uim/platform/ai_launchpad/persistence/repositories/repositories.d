/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (driven port implementations).
module uim.platform.ai_launchpad.persistence.repositories.repositories;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

/// class <Name>Repository : DocumentRepository!(Entity, Id), I<Name>Repository
private string repositoryClass(string name, string entity, string id, string collection) {
  return "class " ~ name ~ "Repository : DocumentRepository!(" ~ entity ~ ", " ~ id ~ "), I" ~ name ~ "Repository {"
    ~ " this(IDocumentStore store) { super(store, Collections." ~ collection ~ "); } }";
}

mixin(repositoryClass("Workspace", "Workspace", "WorkspaceId", "workspaces"));
mixin(repositoryClass("Connection", "Connection", "ConnectionId", "connections"));
mixin(repositoryClass("ResourceGroup", "ResourceGroup", "ResourceGroupId", "resourceGroups"));
mixin(repositoryClass("Scenario", "Scenario", "ScenarioId", "scenarios"));
mixin(repositoryClass("Configuration", "Configuration", "ConfigurationId", "configurations"));
mixin(repositoryClass("Execution", "Execution", "ExecutionId", "executions"));
mixin(repositoryClass("Deployment", "Deployment", "DeploymentId", "deployments"));
mixin(repositoryClass("Model", "Model", "ModelId", "models"));
mixin(repositoryClass("Dataset", "Dataset", "DatasetId", "datasets"));
mixin(repositoryClass("PromptCollection", "PromptCollection", "PromptCollectionId", "promptCollections"));
mixin(repositoryClass("Prompt", "Prompt", "PromptId", "prompts"));
mixin(repositoryClass("Tile", "Tile", "TileId", "tiles"));
mixin(repositoryClass("Role", "Role", "RoleId", "roles"));
mixin(repositoryClass("UserAccount", "UserAccount", "UserAccountId", "users"));

class LogEntryRepository : DocumentRepository!(LogEntry, LogEntryId), ILogEntryRepository {
  this(IDocumentStore store) {
    super(store, Collections.logs);
  }

  size_t removeBefore(TenantId t, long cutoff) {
    return DocumentRepository!(LogEntry, LogEntryId).removeBefore(t, "createdAt", cutoff);
  }

  size_t countSince(TenantId t, long since, bool warningsOnly = false) {
    size_t n;
    foreach (doc; store.all(collection, t.value))
      if (longField(doc, "createdAt") >= since && (!warningsOnly || textField(doc, "severity") != cast(string) LogSeverity.info))
        n++;
    return n;
  }
}

/// All repositories over one document store.
AilpRepositories createRepositories(IDocumentStore store) {
  AilpRepositories r;
  r.workspaces = new WorkspaceRepository(store);
  r.connections = new ConnectionRepository(store);
  r.resourceGroups = new ResourceGroupRepository(store);
  r.scenarios = new ScenarioRepository(store);
  r.configurations = new ConfigurationRepository(store);
  r.executions = new ExecutionRepository(store);
  r.deployments = new DeploymentRepository(store);
  r.models = new ModelRepository(store);
  r.datasets = new DatasetRepository(store);
  r.promptCollections = new PromptCollectionRepository(store);
  r.prompts = new PromptRepository(store);
  r.tiles = new TileRepository(store);
  r.roles = new RoleRepository(store);
  r.users = new UserAccountRepository(store);
  r.logs = new LogEntryRepository(store);
  return r;
}

///
unittest {
  import uim.platform.service.persistence.storages.documents.memory : MemoryDocumentStore;

  auto repos = createRepositories(new MemoryDocumentStore);
  auto t = TenantId("t");
  foreach (i, at; [10L, 20L, 30L]) {
    LogEntry e;
    e.id = LogEntryId("e" ~ i.to!string);
    e.tenantId = t;
    e.createdAt = at;
    e.eventType = "x";
    e.severity = i == 2 ? LogSeverity.warning : LogSeverity.info;
    repos.logs.save(e);
  }
  assert(repos.logs.countSince(t, 20) == 2 && repos.logs.countSince(t, 0, true) == 1);
  assert(repos.logs.removeBefore(t, 25) == 2 && repos.logs.countAll(t) == 1);
}
