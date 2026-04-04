/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.repositories.modules;

import uim.platform.kyma.domain.entities.kyma_module;
import uim.platform.kyma.domain.types;

/// Port: outgoing — Kyma module persistence.
interface ModuleRepository
{
  KymaModule findById(ModuleId id);
  KymaModule findByName(KymaEnvironmentId envId, string name);
  KymaModule[] findByEnvironment(KymaEnvironmentId envId);
  KymaModule[] findByStatus(ModuleStatus status);
  KymaModule[] findByType(ModuleType moduleType);
  void save(KymaModule mod);
  void update(KymaModule mod);
  void remove(ModuleId id);
}
