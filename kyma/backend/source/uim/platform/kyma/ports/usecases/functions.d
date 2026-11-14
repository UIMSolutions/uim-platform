/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.usecases.functions;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Serverless function lifecycle (requires the serverless module).
interface IManageFunctionsUseCase : IManageResource!(ServerlessFunction, ServerlessFunctionId,
    CreateFunctionRequest, UpdateFunctionRequest) {
}
