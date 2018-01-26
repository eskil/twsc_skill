use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :twsc_skill, TwscSkillWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :twsc_skill, TwscSkill.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "twsc_skill_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :oauth2_server, Oauth2Server.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "tradewinds_alexa_dev",
  hostname: "localhost",
  pool_size: 10
