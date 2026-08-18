/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.ports.usecases.scaling_engine;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:
/// Orchestrates the autoscaling decision: evaluate policy rules against
/// the submitted metric and record a scaling history event.
interface IScalingEngineUseCase {
  
  UsecaseResult triggerScaling(TriggerScalingRequest r);
    
}
