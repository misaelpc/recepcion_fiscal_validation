defmodule SchemaValidation.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok,name: __MODULE__ )
  end


  def init(:ok) do
   
    pool_options = [
      name: {:local, :schema_validation_pool},
      worker_module: SchemaValidation.Worker,
      size: 5,
      max_overflow: 10
    ]

    children = [
      :poolboy.child_spec(:schema_validation_pool, pool_options, [])
    ]

    supervise(children, strategy: :one_for_all)

  end

end