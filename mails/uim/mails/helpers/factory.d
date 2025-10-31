/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.mails.helpers.factory;

import uim.mails;

mixin(Version!"test_uim_mails");
@safe:

class DMailFactory : DFactory!IMail {
  mixin(FactoryThis!("Mail"));
}

mixin(FactoryCalls!("Mail"));

unittest {
  auto factory = new DMailFactory();
  assert(testFactory(factory, "Mail"), "Test MailFactory failed");
}
