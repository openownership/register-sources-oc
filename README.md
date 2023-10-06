# Register Sources OC

Register Sources OC is a shared library for the [OpenOwnership](https://www.openownership.org/en/) [Register](https://github.com/openownership/register) project.
It is designed for use with the data published by [OpenCorporates](https://opencorporates.com).

The primary purposes of this library are:

- Providing a client to the Open Corporates API
- Providing typed objects for the Open Corporates data. It makes use of the dry-types and dry-struct gems to specify the different object types allowed in the data returned.
- Persisting the Open Corporates records using Elasticsearch. This functionality includes creating a mapping for indexing the possible fields observed as well as functions for storage and retrieval.
- Using the Elasticsearch database of Open Corporates data as a cache which can be checked before querying their API, to make requests more performant.

## Installation

Install and boot [Register](https://github.com/openownership/register).

Configure your environment using the example file:

```sh
cp .env.example .env
```

## Testing

Run the tests:

```sh
docker compose run sources-oc test
```
