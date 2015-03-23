defmodule SchemaValidation.Worker do
  use GenServer
  
  @doc """
  Starts file worker.
  """
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, [])
  end

  def init(:ok) do
    file_xsd = './BalanzaComprobacion_1_1.xsd'
    {_ok, xsd} = :xmerl_xsd.process_schema(file_xsd)
    {:ok, xsd}
  end

  def validate(file) do
    worker = :poolboy.checkout(:schema_validation)
    file_type = GenServer.call(worker, {:validate, file})
    :poolboy.checkin(:router, worker)
    file_type
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