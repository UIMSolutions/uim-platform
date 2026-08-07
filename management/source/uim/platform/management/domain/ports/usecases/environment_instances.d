/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.usecases.environment_instances;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage environment instance lifecycle (CF, Kyma, ABAP).
interface IManageEnvironmentsUseCase { 

  CommandResult createEnvironment(CreateEnvironmentRequest req);
  CommandResult updateEnvironment(UpdateEnvironmentRequest req);
  CommandResult deprovisionEnvironment(TenantId tenantId, EnvironmentId id);
  
  }
