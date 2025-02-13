defmodule Tax.EventHandler do
  alias __MODULE__
  
  
  @type t :: %EventHandler{
	
  }

  defstruct [
	
  ]

  
  def start_link(opts \\ []), do:
	GenServer.start_link(__MODULE__, opts)

  def init(_placeholder), do:
	{:ok, %{}}
  
end
