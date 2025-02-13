defmodule Tax.App do
  alias Tax.Buffer
  alias Tax.Terminal.State
  
  
  @callback init(Keyword.t) ::
    {:ok, state}
	| {:ok, state, timeout | :hibernate | {:continue, continue_arg :: term}}
	| :ignore
	| {:stop, reason :: any}
  when state: any

  @callback run(State.t) :: :ok
  
  @callback ui(Buffer.t) :: Buffer.t
  
end
