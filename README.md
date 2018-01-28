# TwscSkill

Amazon Alexa skill for access Tradewinds Sailing School & Club reservation system

## Create Amazon Skill

  * Skill information
    * Skill type, "Custom Interaction Model"
    * Name for display, "TWSC"
    * Invocation name for accessing skill, "tradewinds"
  * Interaction model
    * Use the "Skill Builder Beta", but see below for an example.
  * Configuration
    * Service endpoint type, HTTPS
    * Default, https://<heroku-app>.herokuapp.com/api/command
    * Provide geographical endpoints, no
    * Account linking, yes, in this case we'll want it.
      * Authorization URL, https://<heroku-app>.herokuapp.com/oauth/authorize
      * Authorization grant type, implicit grant
    * Permissions, we don't need any of these.
    * Privacy Policy URL, https://<heroku-app>.herokuapp.com/policy
  * SSL Certificate
    * Pick "My development endpoint is a sub-domain of a domain that has a wildcard certificate from a certificate authority"
    

Example interaction model code.

  ```json
  {
    "languageModel": {
      "intents": [
	{
	  "name": "AMAZON.CancelIntent",
	  "samples": []
	},
	{
	  "name": "AMAZON.HelpIntent",
	  "samples": []
	},
	{
	  "name": "AMAZON.StopIntent",
	  "samples": []
	},
	{
	  "name": "AvailableBoats",
	  "samples": [
	    "check tradewinds for available boats",
	    "check tradewinds for available boats this weekend",
	    "check tradewinds for available boats on {Date}",
	    "check tradewinds for available boats on {Day}",
	    "ask tradewinds for available boats on {Day}",
	    "ask tradewinds for available boats on {Date}",
	    "ask tradewinds for available boats this weekend",
	    "ask tradewinds for available boats"
	  ],
	  "slots": [
	    {
	      "name": "Day",
	      "type": "AMAZON.DayOfWeek"
	    },
	    {
	      "name": "Date",
	      "type": "AMAZON.DATE"
	    }
	  ]
	},
	{
	  "name": "CheckReservations",
	  "samples": [
	    "check tradewinds for reservations",
	    "list my tradewinds reservations",
	    "check tradewinds for my reservations",
	    "what are my tradewinds reservations"
	  ],
	  "slots": []
	}
      ],
      "invocationName": "tradewinds"
    }
  }
  ```

## Create phx app

```bash
mix phx.new twsc_skill
cd twsc_skill
git init .
git add *
git commit -m "Initial commit"
git remote add origin git@github.com:eskil/twsc_skill.git
git push origin master
```

Remember to create the `_dev` db in postgres

```sh
$ createdb twsc_skill_dev
```

Create a heroku app and hook it up. I'm not going to go too much into
this, since https://hexdocs.pm/phoenix/heroku.html#content is
authorative here. But here's the unannotated steps.

```
heroku git:remote --app <heroku-app>
```

```
heroku buildpacks:add https://github.com/HashNuke/heroku-buildpack-elixir.git
heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static.git
heroku addons:create heroku-postgresql:hobby-dev
heroku config:set POOL_SIZE=18
heroku config:set SECRET_KEY_BASE="<output from mix phx.gen.secret>"
heroku config:set DATABASE_URL postgres://<user>:<password>@<ec2 host>:<port>/<dbname>
```

```
git push heroku master
heroku run mix ecto.migrate
```
```
  
### Basic pages

To publish Alexa skills, you need some basic pages like privacy
policy, terms and use and contact info. So let's quickly just add
placeholders there.

First we add routes for the new pages.

```diff
diff --git a/lib/twsc_skill_web/router.ex b/lib/twsc_skill_web/router.ex
index 2a90f49..ff1cce9 100644
--- a/lib/twsc_skill_web/router.ex
+++ b/lib/twsc_skill_web/router.ex
@@ -17,6 +17,9 @@ defmodule TwscSkillWeb.Router do
     pipe_through :browser # Use the default browser stack

     get "/", PageController, :index
+    get "/privacy", PageController, :privacy
+    get "/terms", PageController, :terms
+    get "/contact", PageController, :contact
   end

   # Other scopes may use custom stacks.
```

and entries in the `PageController` to access them.

```diff
diff --git a/lib/twsc_skill_web/controllers/page_controller.ex b/lib/twsc_skill_web/controllers/page_
index 1624daf..b5cbc3e 100644
--- a/lib/twsc_skill_web/controllers/page_controller.ex
+++ b/lib/twsc_skill_web/controllers/page_controller.ex
@@ -4,4 +4,16 @@ defmodule TwscSkillWeb.PageController do
   def index(conn, _params) do
     render conn, "index.html"
   end
+
+  def privacy(conn, _params) do
+    render conn, "privacy.html"
+  end
+
+  def terms(conn, _params) do
+    render conn, "terms.html"
+  end
+
+  def contact(conn, _params) do
+    render conn, "contact.html"
+  end
 end
```

You'll now see these appear in your routes.

```bash
$ mix phx.routes
page_path  GET  /         TwscSkillWeb.PageController :index
page_path  GET  /privacy  TwscSkillWeb.PageController :privacy
page_path  GET  /terms    TwscSkillWeb.PageController :terms
page_path  GET  /contact  TwscSkillWeb.PageController :contact
```

We'll want to cleanup in home page a bit, just in case anyone lands
there. So we strip out most of the fluff from the generated index
page.

```diff
diff --git a/lib/twsc_skill_web/templates/page/index.html.eex b/lib/twsc_skill_web/templates/page/index.html.eex
index 0988ea5..7c7c1df 100644
--- a/lib/twsc_skill_web/templates/page/index.html.eex
+++ b/lib/twsc_skill_web/templates/page/index.html.eex
@@ -1,36 +1,13 @@
-<div class="jumbotron">
-  <h2><%= gettext "Welcome to %{name}!", name: "Phoenix" %></h2>
-  <p class="lead">A productive web framework that<br />does not compromise speed and maintainability.</p>
-</div>
-
 <div class="row marketing">
   <div class="col-lg-6">
-    <h4>Resources</h4>
-    <ul>
-      <li>
-        <a href="http://phoenixframework.org/docs/overview">Guides</a>
-      </li>
-      <li>
-        <a href="https://hexdocs.pm/phoenix">Docs</a>
-      </li>
-      <li>
-        <a href="https://github.com/phoenixframework/phoenix">Source</a>
-      </li>
-    </ul>
-  </div>
+  <h4>Alexa Skill for Tradewinds Sailing School and Club.</h4>
+
+  <ul>
+    <li><a href="<%= page_path(@conn, :privacy) %>">Privacy</a>
+    <li><a href="<%= page_path(@conn, :terms) %>">Terms of Use</a>
+    <li><a href="<%= page_path(@conn, :contact) %>">Contact</a>
+  </ul>

   <div class="col-lg-6">
-    <h4>Help</h4>
-    <ul>
-      <li>
-        <a href="http://groups.google.com/group/phoenix-talk">Mailing list</a>
-      </li>
-      <li>
-        <a href="http://webchat.freenode.net/?channels=elixir-lang">#elixir-lang on freenode IRC</a>
-      </li>
-      <li>
-        <a href="https://twitter.com/elixirphoenix">@elixirphoenix</a>
-      </li>
-    </ul>
   </div>
 </div>
```

And the "Get Started" nav pill

```diff
diff --git a/lib/twsc_skill_web/templates/layout/app.html.eex b/lib/twsc_skill_web/templates/layout/app.html.eex
index 4fec23e..18a9235 100644
--- a/lib/twsc_skill_web/templates/layout/app.html.eex
+++ b/lib/twsc_skill_web/templates/layout/app.html.eex
@@ -16,7 +16,7 @@
       <header class="header">
         <nav role="navigation">
           <ul class="nav nav-pills pull-right">
-            <li><a href="http://www.phoenixframework.org/docs">Get Started</a></li>
+            <li></li>
           </ul>
         </nav>
         <span class="logo"></span>
```

Put your own logo (a transparant png, about 100x100 pixels) in
`assets/static/images/logo.png` and change the CSS and delete the old.

```sh
git add assets/static/images/logo.png
git rm assets/static/images/phoenix.png
```

```diff
diff --git a/assets/css/phoenix.css b/assets/css/phoenix.css
index 0b406d7..bdeda8a 100644
--- a/assets/css/phoenix.css
+++ b/assets/css/phoenix.css
@@ -22,12 +22,12 @@ body, form, ul, table {
   border-bottom: 1px solid #e5e5e5;
 }
 .logo {
-  width: 519px;
-  height: 71px;
+  width: 100px;
+  height: 100px;
   display: inline-block;
   margin-bottom: 1em;
-  background-image: url("/images/phoenix.png");
-  background-size: 519px 71px;
+  background-image: url("/images/logo.png");
+  background-size: 100px 100px;
 }

 /* Everything but the jumbotron gets side spacing for mobile first views */
```

Now the home page is fairly simple an clean, and we just add blank
placeholders for the privacy/terms/contact pages for now. When you're
ready to get your app approved, you'll want to update them.

Add `lib/twsc_skill_web/templates/page/contact.html.eex`

```html
<div class="">
  <h2>Contact</h2>
  <p>Contact info goes here.
  </p>
</div>
```

Add `lib/twsc_skill_web/templates/page/privacy.html.eex`

```html
<div class="">
  <h2>Privacy Policy</h2>
  <p>Privacy policy goes here.
  </p>
</div>
```

Add `lib/twsc_skill_web/templates/page/terms.html.eex`

```html
<div class="">
  <h2>Terms of Use</h2>
  <p>Terms of use goes here.
  </p>
</div>
```

Fix up the unit-test for the changed `index.html` and add checks for the new pages.

```diff
diff --git a/test/twsc_skill_web/controllers/page_controller_test.exs b/test/twsc_skill_web/controllers/page_controller_test.exs
index b16d86c..69f86b4 100644
--- a/test/twsc_skill_web/controllers/page_controller_test.exs
+++ b/test/twsc_skill_web/controllers/page_controller_test.exs
@@ -3,6 +3,21 @@ defmodule TwscSkillWeb.PageControllerTest do

   test "GET /", %{conn: conn} do
     conn = get conn, "/"
-    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
+    assert html_response(conn, 200) =~ "Alexa Skill for Tradewinds Sailing School and Club"
+  end
+
+  test "GET /privacy", %{conn: conn} do
+    conn = get conn, "/privacy"
+    assert html_response(conn, 200) =~ "Privacy Policy"
+  end
+
+  test "GET /terms", %{conn: conn} do
+    conn = get conn, "/terms"
+    assert html_response(conn, 200) =~ "Terms of Use"
+  end
+
+  test "GET /contact", %{conn: conn} do
+    conn = get conn, "/contact"
+    assert html_response(conn, 200) =~ "Contact"
   end
 end
```

### Add deps

We need 3 libraries for the alexa hookup.

   * [`col/alexa`](https://github.com/col/alexa), support for implementing alexa skills
   * [`col/alexa_verifier`](https://github.com/col/alexa_verifier), library to verify the cert on requests for you skill
   * [`col/oauth2_server`](https://github.com/col/oauth2_server), Oauth2 server for Phoenix for Alexa skill authorisation

NOTE: `alexa_verifier` and `oauth2_server` from `col` are using older
versions of `plug`, so I'm using my fork that updates deps for now.

```diff
diff --git a/mix.exs b/mix.exs
index 6483457..7d5f353 100644
--- a/mix.exs
+++ b/mix.exs
@@ -40,7 +40,10 @@ defmodule TwscSkill.Mixfile do
       {:phoenix_html, "~> 2.10"},
       {:phoenix_live_reload, "~> 1.0", only: :dev},
       {:gettext, "~> 0.11"},
-      {:cowboy, "~> 1.0"}
+      {:cowboy, "~> 1.0"},
+      {:alexa, github: "col/alexa"},
+      {:alexa_verifier, github: "eskil/alexa_verifier"},
+      {:oauth2_server, github: "eskil/oauth2_server"}
     ]
   end

```

Now to compile these, you need to add configuration statements for
`oauth2_server` and `alexa_verifier`, otherwise you'll get errors like

```
== Compilation error in file lib/oauth2_server/repo.ex ==
** (ArgumentError) missing :adapter configuration in config :oauth2_server, Oauth2Server.Repo
    lib/ecto/repo/supervisor.ex:70: Ecto.Repo.Supervisor.compile_config/2
    lib/oauth2_server/repo.ex:2: (module)
    (stdlib) erl_eval.erl:670: :erl_eval.do_apply/6
```

So add the following to your config files in `config/`.

```diff
diff --git a/config/config.exs b/config/config.exs
index 11b9b85..383eb3b 100644
--- a/config/config.exs
+++ b/config/config.exs
@@ -22,6 +22,13 @@ config :logger, :console,
   format: "$time $metadata[$level] $message\n",
   metadata: [:request_id]

+config :oauth2_server, Oauth2Server.Settings,
+  access_token_expiration: 3600,
+  refresh_token_expiration: 3600
+
+config :alexa_verifier,
+  verifier_client: AlexaVerifier.VerifierClient
+
 # Import environment specific config. This must remain at the bottom
 # of this file so it overrides the configuration defined above.
 import_config "#{Mix.env}.exs"
```

```diff
diff --git a/config/dev.exs b/config/dev.exs
index 6c17696..7e6c037 100644
--- a/config/dev.exs
+++ b/config/dev.exs
@@ -56,3 +56,11 @@ config :twsc_skill, TwscSkill.Repo,
   database: "twsc_skill_dev",
   hostname: "localhost",
   pool_size: 10
+
+config :oauth2_server, Oauth2Server.Repo,
+  adapter: Ecto.Adapters.Postgres,
+  username: "postgres",
+  password: "postgres",
+  database: "twsc_skill_dev",
+  hostname: "localhost",
+  pool_size: 10
```

Note in `prod.exs`, we add the `Oath2Server.Repo` part to ensure
compilation, but we also do a bunch of other things for heroku
deployent. See https://hexdocs.pm/phoenix/heroku.html for details.

```diff
diff --git a/config/prod.exs b/config/prod.exs
index 580b415..ddd2e9c 100644
--- a/config/prod.exs
+++ b/config/prod.exs
@@ -59,6 +59,21 @@ config :logger, level: :info
 #     config :twsc_skill, TwscSkillWeb.Endpoint, server: true
 #

-# Finally import the config/prod.secret.exs
-# which should be versioned separately.
-import_config "prod.secret.exs"
+config :twsc_skill, TwscSkillWeb.Endpoint,
+  load_from_system_env: true,
+  url: [scheme: "https", host: "twsc-skill.herokuapp.com", port: 443],
+    force_ssl: [rewrite_on: [:x_forwarded_proto]],
+  cache_static_manifest: "priv/static/cache_manifest.json",
+  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE")
+
+config :twsc_skill, TwscSkill.Repo,
+  adapter: Ecto.Adapters.Postgres,
+  url: System.get_env("DATABASE_URL"),
+  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
+  ssl: true
+
+config :oauth2_server, Oauth2Server.Repo,
+  adapter: Ecto.Adapters.Postgres,
+  url: System.get_env("DATABASE_URL"),
+  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
+  ssl: true
```

```diff
diff --git a/config/test.exs b/config/test.exs
index bccfb6e..2cd5c18 100644
--- a/config/test.exs
+++ b/config/test.exs
@@ -17,3 +17,11 @@ config :twsc_skill, TwscSkill.Repo,
   database: "twsc_skill_test",
   hostname: "localhost",
   pool: Ecto.Adapters.SQL.Sandbox
+
+config :oauth2_server, Oauth2Server.Repo,
+  adapter: Ecto.Adapters.Postgres,
+  username: "postgres",
+  password: "postgres",
+  database: "twsc_skill_dev",
+  hostname: "localhost",
+  pool_size: 10
```

### Let's add Sentry

If you want extra error reporting etc, create a sentry org/project and get the `SENTRY_DSN`.

```sh
heroku config:set SENTRY_DSN="<sentry dsn>"
```

Add the dependency

```diff
diff --git a/mix.exs b/mix.exs
index 7d5f353..61abc49 100644
--- a/mix.exs
+++ b/mix.exs
@@ -20,7 +20,7 @@ defmodule TwscSkill.Mixfile do
   def application do
     [
       mod: {TwscSkill.Application, []},
-      extra_applications: [:logger, :runtime_tools]
+      extra_applications: [:sentry, :logger, :runtime_tools]
     ]
   end

@@ -41,6 +41,7 @@ defmodule TwscSkill.Mixfile do
       {:phoenix_live_reload, "~> 1.0", only: :dev},
       {:gettext, "~> 0.11"},
       {:cowboy, "~> 1.0"},
+      {:sentry, "~> 6.0.0"},
       {:alexa, github: "col/alexa"},
       {:alexa_verifier, github: "eskil/alexa_verifier"},
       {:oauth2_server, github: "eskil/oauth2_server"}
```

Add the plugs to the router and a test endpoint so we can verify it works.

```diff
diff --git a/lib/twsc_skill_web/router.ex b/lib/twsc_skill_web/router.ex
index ff1cce9..8bc8844 100644
--- a/lib/twsc_skill_web/router.ex
+++ b/lib/twsc_skill_web/router.ex
@@ -1,5 +1,7 @@
 defmodule TwscSkillWeb.Router do
   use TwscSkillWeb, :router
+  use Plug.ErrorHandler
+  use Sentry.Plug

   pipeline :browser do
     plug :accepts, ["html"]
@@ -20,6 +22,7 @@ defmodule TwscSkillWeb.Router do
     get "/privacy", PageController, :privacy
     get "/terms", PageController, :terms
     get "/contact", PageController, :contact
+    get "/test_crash", PageController, :test_crash
   end

   # Other scopes may use custom stacks.
```

```diff
diff --git a/lib/twsc_skill_web/controllers/page_controller.ex b/lib/twsc_skill_web/controllers/page_
index b5cbc3e..f844c75 100644
--- a/lib/twsc_skill_web/controllers/page_controller.ex
+++ b/lib/twsc_skill_web/controllers/page_controller.ex
@@ -16,4 +16,11 @@ defmodule TwscSkillWeb.PageController do
   def contact(conn, _params) do
     render conn, "contact.html"
   end
+
+  def test_crash(conn, _params) do
+    # Intentionally crash so we can verify sentry alerts work.
+    a = 1
+    ^a = 2
+    render conn, "index.html"
+  end
 end
```
