## Setup

- install gems

```sh
$ gem intall sinatra
$ gem install httparty
$ gem install httparty
$ gem install shopify_api
```

- set environment variable

```sh
$ cp .env.skeleton .env
$ vi .env
$ direnv allow
```

## Install app to shop

```sh
$ ngrok http http://localhost:4567
```

- set ngrok url to SHOPIFY_APP_BASE_URL

```sh
$ vi .env
$ direnv allow
```

- run sinatra

```sh
$ ruby main
```

## Get GraphQL Scheme

- install `get-graphql-schema`

```sh
$ npm install -g get-graphql-schema
```

- get GraphQL schema file

```sh
$ echo "{\"data\":`npx get-graphql-schema "https://$SHOPIFY_DOMAIN/admin/api/$SHOPIFY_API_VERSION/graphql.json" -h X-Shopify-Access-Token=$SHOPIFY_TOKEN -j`}" | jq > shopify_graphql_schemas/$SHOPIFY_API_VERSION.json
```

- create `.graphqlrc.json` for LSP

```sh
$ echo "{\"schema\": \"shopify_graphql_schemas/$SHOPIFY_API_VERSION.json\"}" | jq > .graphqlrc.json
```

## Query GraphQL

- create query.gql & variables.json

```sh
$ touch query.gql
$ touch variables.json
```

- edit query.gql & variables.json

```sh
$ vi query.gql
$ vi variables.json
```

- execute GraphQL query

```
$ ruby graphql.rb
```
