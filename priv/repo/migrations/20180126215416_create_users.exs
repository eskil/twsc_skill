defmodule TwscSkill.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :password, :string
      add :twsc_login, :string
      add :twsc_password, :string

      timestamps()
    end

  end
end
