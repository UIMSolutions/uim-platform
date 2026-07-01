/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.gui.controllers.software_component;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.gui.views.software_component;
import uim.platform.abap_environment.presentation.gui.models.software_component;

// mixin(ShowModule!());

class SoftwareComponentGuiController {
  private ManageSoftwareComponentsUseCase usecase;
  private SoftwareComponentWindow view;
  private SoftwareComponentGuiModel model;

  this(ManageSoftwareComponentsUseCase usecase, SoftwareComponentWindow view, SoftwareComponentGuiModel model) {
    this.usecase = usecase;
    this.view    = view;
    this.model   = model;
    connectSignals();
  }

  private void connectSignals() {
  }
}
