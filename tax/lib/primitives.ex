defmodule Tax.Rect do
  alias __MODULE__
  alias Tax.Screen

  @type t :: %Rect{
	x: integer, y: integer,
	w: integer, h: integer
  }
  
  defstruct [
	x: 0,
	y: 0,
	w: Screen.size[:w],
	h: Screen.size[:h]
  ]

  
  @spec fullscreen() :: Rect.t
  def fullscreen, do: %Rect{}


  @spec length(__MODULE__.t) :: integer
  def length(%Rect{w: w, h: h}), do: w*h
  
end
