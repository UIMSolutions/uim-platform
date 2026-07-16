/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.helpers.convert;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:

Address[] toAddresses(Json json) {
  Address[] result;

  foreach (item; json.getArray("addresses")) {
    if (!item.isObject)
      continue;

    auto address = Address();
    address.formatted = item.getString("formatted");
    address.streetAddress = item.getString("streetAddress");
    address.locality = item.getString("locality");
    address.region = item.getString("region");
    address.postalCode = item.getString("postalCode");
    address.country = item.getString("country");
    address.type = item.getString("type");
    address.primary = getBoolean(item, "primary");

    result ~= address;
  }

  return result;
}

UserName toUserName(Json json) {
  if (!json.isObject)
    return UserName.init;

  if ("name" !in json)
    return UserName.init;

  auto value = json["name"];
  if (!value.isObject)
    return UserName.init;

  auto userName = UserName();
  userName.formatted = value.getString("formatted");
  userName.familyName = value.getString("familyName");
  userName.givenName = value.getString("givenName");
  userName.middleName = value.getString("middleName");
  userName.honorificPrefix = value.getString("honorificPrefix");
  userName.honorificSuffix = value.getString("honorificSuffix");

  return userName;
}
