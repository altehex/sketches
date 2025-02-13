defmodule Tax.Context do
  alias __MODULE__

  
  @type t :: %Context{
	eventHandlers: Keyword.t,
	terms:         Keyword.t
  }
  
  defstruct [
	eventHandlers: [],
	terms:         []
  ]
  
end



defmodule Tax do
  alias Tax.Context
  
  require Logger
  
  use DynamicSupervisor
  
  
  @spec start_link(Keyword.t) :: DynamicSupervisor.on_start
	
  def start_link(args), do:
	DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)

  def init(_args), do: {:ok, %Context{}}
  

  @spec start_child(module, module, Keyword.t)
    :: DynamicSupervisor.on_start_child
  
  def start_child(child, id, args \\ []), do:
	__MODULE__
    |> DynamicSupervisor.start_child(
	     %{ id: id, start: {child, :start_link, [args]} }
	   )

end ## Tax
