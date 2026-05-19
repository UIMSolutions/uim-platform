/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.enums.subscription_status;
import std.conv : to;
mixin template ShowModule() { static if (__traits(compiles, { import vibe.d; })) {} }
@safe:
enum SubscriptionStatus { active, inactive, pending, error_ }
