/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.enumerations.components;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Kind of a software component.
enum ComponentType {
  development,
  businessConfiguration,
}

/// Clone / pull status of a software component.
///
///   notCloned → cloning → cloned → pulling → cloned   (error from cloning / pulling)
enum ComponentStatus {
  notCloned,
  cloning,
  cloned,
  pulling,
  error,
}

/// Branch strategy of a software component.
enum BranchStrategy {
  main,
  release,
  feature,
  correction,
}
