# As the title says
* Dont' forget to `sudo usermod -aG docker $(whoami)`
* delete /root/.docker/config.json
* use gcr
* don't use sudo
# cloud build
* `cloud-build-local --config=cloudbuild.yml --dryrun=false --push .`