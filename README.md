# Parking Project

A phoenix app that allows someone to book a parking space.

## Installing Docker and Docker-compose

**These instructions are for linux**

**I have no idea how to go about it in Windows tbh**

Install docker and docker-compose as described [here](https://github.com/brurucy/parking_project/blob/master/Installing_docker.md)

## Running Docker and Docker-compose

1. `cd parking_project`

    `mix deps.get`
    
    `cd assets && npm install`
    
    `mix ecto.create`

2. `docker pull eu.gcr.io/XXXX/parking_project` **this will fail if you are not logged in gcloud**

3. `docker-compose -f docker-compose-test.yml up -d`

4. go to `localhost:4000`, you should see phoenix

5. use `docker-compose docker-compose-dev.yml down` to stop everything. **make sure to be in the project folder in order to do that**
