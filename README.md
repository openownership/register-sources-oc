# Register Sources OC

Register Sources OC is designed for inclusion as a library for use with Open Corporates Bulk Data and API.

There are four primary purposes for this library:

- Provides a client to the Open Corporates API
- Providing typed objects for the Open Corporates data. It makes use of the dry-types and dry-struct gems to specify the different object types allowed in the data returned.
- For use with an Elasticsearch database for
persisting the Open Corporates records from their bulk monthly export. This functionality includes creating a mapping for indexing the possible fields observed as well as functions for storage and retrieval.
- For using the Elasticsearch database of Open Corporates data as a cache which can be checked before querying their API, to make requests more performant.

This library does not perform any ingestion of the OC records, which is the purpose of the register_ingester_oc gem.

## Configuration

The gem requires connection to an Elasticsearch Cluster. It has been tested with ES version v7.17.

These credentials should be set in some ENV variables:
```
ELASTICSEARCH_HOST=
ELASTICSEARCH_PORT=
ELASTICSEARCH_PROTOCOL=
ELASTICSEARCH_SSL_VERIFY=
ELASTICSEARCH_PASSWORD=

OC_API_TOKEN=
OC_API_TOKEN_PROTECTED=
```

As an initial setup stage, the index should be created:
```
require 'register_sources_oc/services/es_index_creator'

index_creator = RegisterSourcesOc::Services::EsIndexCreator.new
index_creator.create_companies_index
```

## Testing

The tests are executed using Docker and Docker Compose. To trigger the tests, run:
```
bin/test
```

Note: If the integration tests fail due to connection failure, it is probable the container is taking a while to start - check the ES container is healthy and try again.
