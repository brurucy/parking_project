param([string]$environment="test") #default to test environment

if($environment -eq "prod"){
   Throw "You cannot run this script against the prod evironment. You must initialize prod manually"
}

$env:MIX_ENV = $environment
mix ecto.drop
mix ecto.create
mix ecto.migrate
Remove-Item Env:\MIX_ENV #Reset the environment setting.