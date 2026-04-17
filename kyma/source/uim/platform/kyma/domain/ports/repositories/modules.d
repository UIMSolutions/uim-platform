/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.repositories.modules;

// import uim.platform.kyma.domain.entities.kyma_module;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Port: outgoing — Kyma module persistence.
interface ModuleRepository {
  bool existsById(KymaModuleId moduleId);
  KymaModule findById(KymaModuleId moduleId);

  bool existsByName(KymaEnvironmentId environmentId, string name);
  KymaModule findByName(KymaEnvironmentId environmentId, string name);

  KymaModule[] findByEnvironment(KymaEnvironmentId environmentId);
  KymaModule[] findByStatus(ModuleStatus status);
  KymaModule[] findByType(ModuleType moduleType);

  void save(KymaModule mod);
  void update(KymaModule mod);
  void remove(KymaModuleId moduleId);
}
