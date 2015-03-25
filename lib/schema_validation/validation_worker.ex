defmodule SchemaValidation.Worker do
  use GenServer
  
  @doc """
  Starts file worker.
  """
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, [])
  end

  def init(state) do
    file_xsd = './BalanzaComprobacion_1_1.xsd'
    {_ok, xsd} = :xmerl_xsd.process_schema(file_xsd)
    {:ok, xsd}
  end

  def validate(file) do
    :poolboy.transaction(:schema_validation_pool, fn(worker)-> :gen_server.call(worker, {:validate, file}) end)
  end


  def handle_call({:validate, file}, _from, xsd) do
    case :xmerl_xsd.validate(file, xsd) do 
      {:error, validation_errors} ->
        parse_errors(validation_errors)
        { :reply, {:error, "Not schema compliant"}, xsd}
      {_xml,_newState} ->   
        { :reply,{:ok,"Schema Valid"}, xsd}
    end
  end

  def parse_errors([]), do: []

  def parse_errors([head | tail]) do
    IO.puts "***********************"
    IO.inspect head
    parse_errors(tail)
  end

end