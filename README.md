* Installing Docker and Docker-compose

**These instructions are for linux**

**I have no idea how to go about it in Windows tbh**

Install docker and docker-compose as described on Installing_docker.md

* Running Docker and Docker-compose

1. `cd parking_project`

2. `sudo docker build -t parkingproject:0.1 .` **do not forget about the . in the end**

3. `sudo docker-compose -f docker-compose.yml up -d`

4. go to `localhost:4000`, you should see phoenix

5. use `sudo docker-compose down` to stop everything. **make sure to be in the project folder in order to do that**

* F.A.Q

1. Why do we have to use docker?

Having a docker image ready will make our lives easier for CI.

2. If I change something in a file, do I have to run docker build and else again?

No. The development experience should be pretty much the same as without docker.

3. How can I run `mix test`?

`docker exec -it parking_project_web_1 bash`

`mix test`

4. How can I reset the db inside?

Just `sudo docker-compose down` then `sudo docker-compose -f docker-compose.yml up -d`

Avoid interacting with the container directly.