/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.web.views.transport_request;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.web.models.transport_request;

// // mixin(ShowModule!());
@safe:

class TransportRequestHtmlView {
  string renderList(TransportRequestViewModel[] models) {
    return string.init;
  }

  string renderDetail(TransportRequestViewModel model) {
    return string.init;
  }

  string renderForm(TransportRequestViewModel model = TransportRequestViewModel.init) {
    return string.init;
  }
}
