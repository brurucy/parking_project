# Parking Project

## Installing Docker and Docker-compose

**These instructions are for linux**

**I have no idea how to go about it in Windows tbh**

Install docker and docker-compose as described [here](https://github.com/brurucy/parking_project/blob/master/Installing_docker.md)

## Running Docker and Docker-compose

1. `cd parking_project`

    `mix deps.get`
    
    `cd assets && npm install`
    
    `mix ecto.create`

2. `docker pull -t parkingproject:latest .` **do not forget about the . in the end**

3. `docker-compose -f docker-compose-test.yml up -d`

4. go to `localhost:4000`, you should see phoenix

5. use `docker-compose docker-compose-dev.yml down` to stop everything. **make sure to be in the project folder in order to do that**

## F.A.Q

1. Why do we have to use docker?

Having a docker image ready will make our lives easier for CI.

2. If I change something in a file, do I have to run docker build and else again?

No. The development experience should be pretty much the same as without docker.

3. How can I test the hard way(won't spawn a new container)?

`docker exec -it <container_id> bash`

`mix test` or `mix white_bread.run`

4. How can I test the easy way(will spawn a new container)?

`sudo docker-compose run web mix test`

5. How can I reset the db?

Just `sudo docker-compose -f docker-compose-test.yml down` then `sudo docker-compose -f docker-compose-test.yml up -d`

Avoid interacting with the container directly
