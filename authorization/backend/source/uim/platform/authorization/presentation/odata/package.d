/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// OData v4 endpoint & $metadata for SAP Fiori (generic engine of uim-platform:service).
module uim.platform.authorization.presentation.odata;

public {
  import uim.platform.service.presentation.odata;
  import uim.platform.authorization.presentation.odata.model;
  import uim.platform.authorization.presentation.odata.errors;
  import uim.platform.authorization.presentation.odata.serializers;
  import uim.platform.authorization.presentation.odata.payloads;
  import uim.platform.authorization.presentation.odata.engine;
}
