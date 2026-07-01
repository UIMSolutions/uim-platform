/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.gui.controllers.transport_request;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.gui.views.transport_request;
import uim.platform.abap_environment.presentation.gui.models.transport_request;

// mixin(ShowModule!());

class TransportRequestGuiController {
  private ManageTransportRequestsUseCase usecase;
  private TransportRequestWindow view;
  private TransportRequestGuiModel model;

  this(ManageTransportRequestsUseCase usecase, TransportRequestWindow view, TransportRequestGuiModel model) {
    this.usecase = usecase;
    this.view    = view;
    this.model   = model;
    connectSignals();
  }

  private void connectSignals() {
  }
}
