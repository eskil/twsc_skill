defmodule TwscSkill.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias TwscSkill.Accounts.User


  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :twsc_login, :string
    field :twsc_password, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :twsc_login, :twsc_password])
    |> validate_required([:name, :email, :password, :twsc_login, :twsc_password])
  end
end
