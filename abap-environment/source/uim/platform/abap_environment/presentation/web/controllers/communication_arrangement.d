/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.web.controllers.communication_arrangement;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

class CommunicationArrangementWebController : ManageController {
  private ManageCommunicationArrangementsUseCase usecase;

  this(ManageCommunicationArrangementsUseCase usecase) {
    this.usecase = usecase;
  }
}
