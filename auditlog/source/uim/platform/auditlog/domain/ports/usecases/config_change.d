/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.ports.usecases.config_change;

import uim.platform.auditlog; 

mixin(ShowModule!());

@safe:
interface WriteConfigChangeUseCase { 

  UsecaseResult writeChange(WriteConfigChangeLogRequest req);

}
