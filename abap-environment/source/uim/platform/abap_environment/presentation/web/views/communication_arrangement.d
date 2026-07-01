/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.web.views.communication_arrangement;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.web.models.communication_arrangement;

// mixin(ShowModule!());
@safe:

class CommunicationArrangementHtmlView {
  string renderList(CommunicationArrangementViewModel[] models) {
    return string.init;
  }

  string renderDetail(CommunicationArrangementViewModel model) {
    return string.init;
  }

  string renderForm(CommunicationArrangementViewModel model = CommunicationArrangementViewModel.init) {
    return string.init;
  }
}
