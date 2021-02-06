# Parking Project

A phoenix app that allows someone to book a parking space in Tartu's Kasklinn.

## How to run it

1. `cd parking_project`

    `mix deps.get`
    
    `cd assets && npm install`
    
    `mix ecto.create`

2. `docker-compose -f docker-compose-test.yml up -d`

3. go to `localhost:4000`, you should see phoenix

4. use `docker-compose docker-compose-dev.yml down` to stop everything. **make sure to be in the project folder in order to do that**
