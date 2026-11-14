/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.enumerations.catalog;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Where an extension comes from.
enum ExtensionScope {
  predefined, /// part of a dev space type (protected)
  additional, /// SAP extension that can be added to a dev space
  thirdParty, /// open-vsx / customer extension
}

/// Availability of an extension in the catalogue.
enum ExtensionStatus {
  active,
  inactive, /// temporarily withdrawn: cannot be added to dev spaces
  deprecated_, /// "deprecated": kept for existing dev spaces, not for new ones
}

/// Category of a project template (generator).
enum TemplateCategory {
  general,
  sapFiori,
  sapCap,
  sapHana,
  sapMdk,
  sapWorkflow,
}

///
unittest {
  assert(enumText(ExtensionStatus.deprecated_) == "deprecated");
  assert(parseEnum!ExtensionStatus("Deprecated", ExtensionStatus.active) == ExtensionStatus.deprecated_);
  assert(enumTexts!TemplateCategory[0] == "general");
}
