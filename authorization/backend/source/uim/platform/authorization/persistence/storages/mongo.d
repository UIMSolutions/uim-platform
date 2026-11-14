/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// MongoDB document store: one collection, one document per
/// (collection, tenant, key) with the record stored as native BSON.
module uim.platform.authorization.persistence.storages.mongo;

import vibe.data.bson : Bson;
import vibe.db.mongo.mongo : connectMongoDB;
import vibe.db.mongo.collection : MongoCollection, ReplaceOptions;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class MongoDocumentStore : IDocumentStore {
  protected MongoCollection documents;

  /// Throws if the server cannot be reached.
  this(string uri, string database, string collection) @trusted {
    documents = connectMongoDB(uri).getDatabase(database)[collection];
  }

  protected static Bson filterOf(string collection, string tenantId) @trusted {
    return Bson(["c": Bson(collection), "t": Bson(tenantId)]);
  }

  protected static Bson keyOf(string collection, string tenantId, string key) @trusted {
    return Bson(["_id": Bson(collection ~ "/" ~ tenantId ~ "/" ~ key)]);
  }

  Json[] all(string collection, string tenantId) @trusted {
    Json[] result;
    foreach (doc; documents.find(filterOf(collection, tenantId)))
      result ~= doc["doc"].toJson;
    return result;
  }

  Json get(string collection, string tenantId, string key) @trusted {
    auto doc = documents.findOne(keyOf(collection, tenantId, key));
    return doc.isNull ? Json(null) : doc["doc"].toJson;
  }

  void put(string collection, string tenantId, string key, Json document) @trusted {
    auto doc = Bson.emptyObject;
    doc["_id"] = Bson(collection ~ "/" ~ tenantId ~ "/" ~ key);
    doc["c"] = Bson(collection);
    doc["t"] = Bson(tenantId);
    doc["k"] = Bson(key);
    doc["doc"] = Bson.fromJson(document);
    ReplaceOptions options;
    options.upsert = true;
    documents.replaceOne(keyOf(collection, tenantId, key), doc, options);
  }

  bool remove(string collection, string tenantId, string key) @trusted {
    return documents.deleteOne(keyOf(collection, tenantId, key)).deletedCount > 0;
  }

  size_t count(string collection, string tenantId) @trusted {
    return cast(size_t) documents.countDocuments(filterOf(collection, tenantId));
  }
}
