defmodule SchemaValidation do
  use Application

  def start(_type, _args) do
    SchemaValidation.Supervisor.start_link
  end
end
