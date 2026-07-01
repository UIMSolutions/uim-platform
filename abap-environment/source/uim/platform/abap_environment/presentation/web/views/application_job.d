/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.web.views.application_job;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.web.models.application_job;

// mixin(ShowModule!());
@safe:

class ApplicationJobHtmlView {
  string renderList(ApplicationJobViewModel[] models) {
    return string.init;
  }

  string renderDetail(ApplicationJobViewModel model) {
    return string.init;
  }

  string renderForm(ApplicationJobViewModel model = ApplicationJobViewModel.init) {
    return string.init;
  }
}
