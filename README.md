# Dada

[ ![Codeship Status for Jablay-NTHU/dada](https://app.codeship.com/projects/12bc5360-423a-0136-4f57-52cc51e21808/status?branch=master)](https://app.codeship.com/projects/291495)


Dada is an API to call another API and store the data and retrieve it to another format (csv, etc)

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/projects/`: returns all projects IDs
- GET `api/v1/projects/[ID_Pro]`: returns details about a single projects with given ID Project
- GET `api/v1/projects/[ID_Pro]/request/[ID_Req]`: returns details about a single request with given ID Project
- GET `api/v1/projects/[ID_Pro]/request/[ID_Req]/responses/[ID_Res]`: returns details about a single responses with given ID

- POST `api/v1/accounts/owner_ids/[OWNER_ID]/project`: creates a new project for a user
- POST `api/v1/projects/[IDP]/request/[]`: creates a new request for API Call with given ID project

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
rackup
```