defmodule TwscSkill.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias TwscSkill.Accounts.User


  schema "users" do
    field :email, :string
    field :name, :string, unique: true
    field :password, :string, virtual: true
    field :password_hash, :string
    field :twsc_login, :string
    field :twsc_password, :string

    timestamps()
  end

  @required_fields [:email, :twsc_login, :twsc_password]

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password_hash, :twsc_login, :twsc_password])
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/@/)
  end

  @doc """
  Build a changeset for registration.
  Validates password and ensures it gets hashed.
  """
  def registration_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 100)
    |> hash_password
  end

  @doc """
  Adds the hashed password to the changeset.
  """
  defp hash_password(changeset) do
    case changeset do
      # If it's a valid password, grab (by matching) the password,
      # change the changeset by inserting the hashed password.
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))
      # Anything else (eg. not valid), return untouched.
      _ -> changeset
    end
  end
end
