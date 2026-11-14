/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.ports.usecases.manage_task_providers;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface IManageTaskProviders {
  TaskProvider[] listTaskProviders(TenantId tenantId);
  TaskProvider getTaskProvider(TenantId tenantId, TaskProviderId id);
  TaskProvider createTaskProvider(CreateTaskProviderRequest request);
  TaskProvider updateTaskProvider(UpdateTaskProviderRequest request);
  /// Refused while definitions or tasks reference the provider.
  void deleteTaskProvider(TenantId tenantId, TaskProviderId id);
}

interface ISyncTaskProviders {
  /// Pull the provider's tasks and upsert them by external id.
  SyncResult sync(TenantId tenantId, TaskProviderId id, UserId actor);
  /// Sync every provider that can sync (active, with endpoint).
  SyncResult[] syncAll(TenantId tenantId, UserId actor);
}
