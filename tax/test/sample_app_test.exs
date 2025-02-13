defmodule SampleAppTest do
  use ExUnit.Case

  alias Tax.Rect
  alias Tax.Terminal

  require Logger
  

  setup do
	with {:ok, ds} <- Tax.start_link(TestApp),
	     {:ok, _term, state} <- Tax.start_child(Terminal, "someid")
	do
	  {:ok, ds: ds, state: state}
	end
  end

  
  test "Get-set with agent", context do
	with state <- context[:state],
	     initialArea <- Terminal.get(:area, state)
	do
	  Logger.debug("Initial area: #{initialArea |> inspect()}")
	
	  assert Terminal.update(%Rect{x: 54, y: 23, h: 45, w: 11}, :area, state) == :ok
	  assert Terminal.get(:area, state) == %Rect{x: 54, y: 23, h: 45, w: 11}
	
	  Logger.debug("Current area: #{Terminal.get(:area, state) |> inspect()}")
 	  Logger.debug("Restoring terminal area.")

	  assert Terminal.update(initialArea, :area, state) == :ok
	end
  end

  
  test "Draw test", context do
	with state = context[:state] do
	  Terminal.draw(state, &TestApp.ui/1)
	end
  end

end


defmodule TestApp do
  @behaviour Tax.App
  
  alias __MODULE__
  alias Tax.Terminal
  

  @impl true
  def init(_opts) do

  end
	
  @impl true
  def run(termState) do
	Terminal.draw(termState, &__MODULE__.ui/1)
	run(termState)
  end
	
  @impl true
  def ui(fb) do
	fb
  end
  
end
