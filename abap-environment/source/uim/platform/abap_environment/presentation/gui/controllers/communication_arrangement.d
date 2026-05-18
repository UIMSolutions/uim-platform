/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.gui.controllers.communication_arrangement;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.gui.views.communication_arrangement;
import uim.platform.abap_environment.presentation.gui.models.communication_arrangement;

mixin(ShowModule!());

class CommunicationArrangementGuiController {
  private ManageCommunicationArrangementsUseCase usecase;
  private CommunicationArrangementWindow view;
  private CommunicationArrangementGuiModel model;

  this(ManageCommunicationArrangementsUseCase usecase, CommunicationArrangementWindow view, CommunicationArrangementGuiModel model) {
    this.usecase = usecase;
    this.view    = view;
    this.model   = model;
    connectSignals();
  }

  private void connectSignals() {
  }
}
