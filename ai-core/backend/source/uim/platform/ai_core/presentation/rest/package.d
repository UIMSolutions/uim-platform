/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// vibe.d REST interfaces. The AI API v2 is implemented as a hand written
/// HTTP controller (presentation.http.controllers.ai_api) because its wire
/// format (AI-Resource-Group header, {count, resources} envelopes, bulk
/// PATCH) does not map onto vibe.d's generated REST interfaces.
module uim.platform.ai_core.presentation.rest;
