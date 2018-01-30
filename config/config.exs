# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :twsc_skill,
  ecto_repos: [TwscSkill.Repo]

# Configures the endpoint
config :twsc_skill, TwscSkillWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AemvTUfRHYO5EQPFHCRpEHSsVOoYmWDHOrzZHDmwagjxZxboLE8k+iiMiigmvtsu",
  render_errors: [view: TwscSkillWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TwscSkill.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :oauth2_server, Oauth2Server.Settings,
  access_token_expiration: 3600,
  refresh_token_expiration: 3600

config :alexa_verifier,
  verifier_client: AlexaVerifier.VerifierClient

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: Mix.env,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!,
  tags: %{
    env: "production"
  },
  included_environments: [:prod]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
