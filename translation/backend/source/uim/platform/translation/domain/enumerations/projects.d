/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.enumerations.projects;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Where the source texts of a translation project come from.
enum ProjectType {
  file, /// uploaded properties / XLIFF / JSON files
  git, /// a Git repository (repositoryUrl, baseBranch)
  abap, /// an ABAP system (abapSystemId)
  api, /// texts pushed through the API
}

/// Lifecycle of a translation project.
enum ProjectStatus {
  draft, /// being set up, not translated yet
  active, /// ready for translation
  inProgress, /// some texts are not translated into every target language
  completed, /// every text is translated into every target language
  archived, /// read-only
}

/// Translation state of a project text across the project's target languages.
enum TextStatus {
  untranslated, /// no target language translated
  partial, /// some target languages translated
  translated, /// every target language translated
  reviewed, /// every target language translated and reviewed
}

/// What kind of software text is translated (influences length checks and style).
enum TextType {
  uiText, /// button labels, menu items, field labels
  tooltip,
  errorMessage,
  documentation,
  notification,
  emailBody,
  reportTitle,
  log,
}
