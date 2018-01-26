defmodule TwscSkillWeb.PageController do
  use TwscSkillWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
