/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.gui.controllers.application_job;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.gui.views.application_job;
import uim.platform.abap_environment.presentation.gui.models.application_job;

// mixin(ShowModule!());

class ApplicationJobGuiController {
  protected ManageApplicationJobsUseCase usecase;
  protected ApplicationJobWindow view;
  protected ApplicationJobGuiModel model;

  this(ManageApplicationJobsUseCase usecase, ApplicationJobWindow view, ApplicationJobGuiModel model) {
    this.usecase = usecase;
    this.view    = view;
    this.model   = model;
    connectSignals();
  }

  private void connectSignals() {
  }
}
