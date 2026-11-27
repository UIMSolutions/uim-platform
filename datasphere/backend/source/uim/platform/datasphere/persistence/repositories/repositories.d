/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (driven port implementations).
module uim.platform.datasphere.persistence.repositories.repositories;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class SpaceRepository : DocumentRepository!(Space, SpaceId), ISpaceRepository {
  this(IDocumentStore store) {
    super(store, Collections.spaces);
  }
}

class SpaceMemberRepository : DocumentRepository!(SpaceMember, SpaceMemberId), ISpaceMemberRepository {
  this(IDocumentStore store) {
    super(store, Collections.members);
  }
}

class ConnectionRepository : DocumentRepository!(Connection, ConnectionId), IConnectionRepository {
  this(IDocumentStore store) {
    super(store, Collections.connections);
  }
}

class RemoteTableRepository : DocumentRepository!(RemoteTable, RemoteTableId), IRemoteTableRepository {
  this(IDocumentStore store) {
    super(store, Collections.remoteTables);
  }
}

class DataViewRepository : DocumentRepository!(DataView, DataViewId), IDataViewRepository {
  this(IDocumentStore store) {
    super(store, Collections.views);
  }
}

class DataFlowRepository : DocumentRepository!(DataFlow, DataFlowId), IDataFlowRepository {
  this(IDocumentStore store) {
    super(store, Collections.dataFlows);
  }
}

class TaskRepository : DocumentRepository!(DataTask, TaskId), ITaskRepository {
  this(IDocumentStore store) {
    super(store, Collections.tasks);
  }
}

class TaskChainRepository : DocumentRepository!(TaskChain, TaskChainId), ITaskChainRepository {
  this(IDocumentStore store) {
    super(store, Collections.taskChains);
  }
}

class TaskRunRepository : DocumentRepository!(TaskRun, TaskRunId), ITaskRunRepository {
  this(IDocumentStore store) {
    super(store, Collections.runs);
  }

  size_t removeFinishedBefore(TenantId t, long cutoff) {
    size_t n;
    foreach (doc; store.all(collection, t.value)) {
      auto status = textField(doc, "status");
      auto finished = status != cast(string) RunStatus.running && status != cast(string) RunStatus.notRun;
      if (finished && longField(doc, "finishedAt") < cutoff && store.remove(collection, t.value, textField(doc, "id")))
        n++;
    }
    return n;
  }
}

class DataAccessControlRepository : DocumentRepository!(DataAccessControl, DataAccessControlId), IDataAccessControlRepository {
  this(IDocumentStore store) {
    super(store, Collections.accessControls);
  }
}

class CatalogAssetRepository : DocumentRepository!(CatalogAsset, CatalogAssetId), ICatalogAssetRepository {
  this(IDocumentStore store) {
    super(store, Collections.catalog);
  }
}

class UserAccountRepository : DocumentRepository!(UserAccount, UserAccountId), IUserAccountRepository {
  this(IDocumentStore store) {
    super(store, Collections.users);
  }
}

/// All repositories over one document store.
DspRepositories createRepositories(IDocumentStore store) {
  DspRepositories r;
  r.spaces = new SpaceRepository(store);
  r.members = new SpaceMemberRepository(store);
  r.connections = new ConnectionRepository(store);
  r.remoteTables = new RemoteTableRepository(store);
  r.views = new DataViewRepository(store);
  r.dataFlows = new DataFlowRepository(store);
  r.tasks = new TaskRepository(store);
  r.taskChains = new TaskChainRepository(store);
  r.runs = new TaskRunRepository(store);
  r.accessControls = new DataAccessControlRepository(store);
  r.catalog = new CatalogAssetRepository(store);
  r.users = new UserAccountRepository(store);
  return r;
}
