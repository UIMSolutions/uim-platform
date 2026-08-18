/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.usecases.log_streams;

import uim.platform.logging;

mixin(ShowModule!());

@safe:
interface IManageLogStreamsUseCase { 

  UsecaseResult createStream(CreateLogStreamRequest req);

  UsecaseResult updateStream(UpdateLogStreamRequest req);

  bool hasStream(TenantId tenantId, LogStreamId id);

  LogStream getStream(TenantId tenantId, LogStreamId id);

  LogStream[] listStreams(TenantId tenantId);

  UsecaseResult deleteStream(TenantId tenantId, LogStreamId id);

}

