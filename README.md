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
