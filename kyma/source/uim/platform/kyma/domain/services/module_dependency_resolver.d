/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.services.module_dependency_resolver;

// import uim.platform.kyma.domain.entities.kyma_module;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Domain service: resolves module dependencies and validates enable/disable operations.
class ModuleDependencyResolver {
  /// Check whether all required dependencies are satisfied for enabling a module.
  bool canEnable(KymaModule mod, KymaModule[] allModules) {
    foreach (reqName; mod.requiredModules) {
      bool found = false;
      foreach (existing; allModules) {
        if (existing.name == reqName && existing.status == ModuleStatus.enabled)
        {
          found = true;
          break;
        }
      }
      if (!found)
        return false;
    }
    return true;
  }

  /// Find modules that depend on a given module (for safe disable checks).
  string[] findDependents(string moduleName, KymaModule[] allModules) {
    string[] dependents;
    foreach (m; allModules) {
      if (m.status != ModuleStatus.enabled)
        continue;
      foreach (dep; m.requiredModules) {
        if (dep == moduleName)
        {
          dependents ~= m.name;
          break;
        }
      }
    }
    return dependents;
  }

  /// Get the list of unsatisfied dependencies for a module.
  string[] getUnsatisfiedDependencies(KymaModule mod, KymaModule[] allModules) {
    string[] missing;
    foreach (reqName; mod.requiredModules) {
      bool found = false;
      foreach (existing; allModules) {
        if (existing.name == reqName && existing.status == ModuleStatus.enabled)
        {
          found = true;
          break;
        }
      }
      if (!found)
        missing ~= reqName;
    }
    return missing;
  }
}
