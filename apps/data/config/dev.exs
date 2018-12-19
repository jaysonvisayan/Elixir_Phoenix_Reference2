use Mix.Config

config :data, Data.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "medical_dev",
  pool_size: 2,
  types: Data.PostgrexTypes

#Staging Db
# config :data, Data.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   username: "postgres",
#   password: "postgres",
#   database: "medical_ist",
#   hostname: "172.16.45.77",
#   pool_size: 10

