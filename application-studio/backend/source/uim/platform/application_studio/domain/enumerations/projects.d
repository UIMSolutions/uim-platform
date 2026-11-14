/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.enumerations.projects;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Kind of project (decides compatible templates, dev space types and deploy targets).
enum ProjectType {
  basic,
  sapFiori,
  sapFioriElements,
  sapUi5,
  capNodeJs,
  capJava,
  hanaNative,
  mdk,
  workflow,
  multitarget,
  sideBySideExtension,
}

/// True for projects whose result is a UI (HTML5 / ABAP repository deployable).
bool isUiProject(ProjectType t) pure nothrow {
  with (ProjectType)
    return t == sapFiori || t == sapFioriElements || t == sapUi5 || t == mdk;
}

/// Lifecycle status of a project. building / deploying are set by build configurations.
enum ProjectStatus {
  active,
  building,
  deploying,
  archived,
  error,
}

///
unittest {
  assert(ProjectType.sapFioriElements.isUiProject && !ProjectType.capJava.isUiProject);
  assert(parseEnum!ProjectType("cap-node-js", ProjectType.basic) == ProjectType.capNodeJs);
}
