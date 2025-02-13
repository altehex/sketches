defmodule Tax.Buffer do
  alias __MODULE__
  alias Tax.Rect
  
  
  @type t :: %Buffer{
	raw:  IO.ANSI.ansidata,
	size: integer
  }

  defstruct [
	raw:  ~c"",
	size: 0
  ]


  @spec allocate(integer) :: IO.chardata

  def allocate(0), do: ~c" "
  
  def allocate(size), do:
    [~c" " | allocate(size-1)]
  
  
  @spec from_rect(Rect.t) :: {:ok, __MODULE__.t}
  
  def from_rect(rect), do:
    rect |> Rect.length() |> from_size()
  
  
  @spec from_size(integer) :: {:ok, __MODULE__.t}
  
  def from_size(size), do:
	%Buffer{
	   size: size,
	   raw: allocate(size)
	}
  

  @spec resize(__MODULE__.t, integer, integer)
    :: {:ok, __MODULE__.t}
	
  def resize(%Buffer{size: _size} = buffer,
	         newSize,
	         _offset \\ 0) do
	# save the contents of the old buffer
	# using the specified offset
	# when applying the offset treat the buffer like a ring
	# return resized buffer
	{:ok, %Buffer{buffer | size: newSize}}
  end


  @spec resize_with_boundaries(__MODULE__.t, integer, integer)
    :: {:ok, __MODULE__.t}
  
  def resize_with_boundaries(%Buffer{size: size} = buffer,
	                         newSize,
	                         offset)
	when newSize >= size+offset do
	{:ok, %Buffer{buffer | size: newSize}}
  end

  def resize_with_boundaries(%Buffer{size: size} = buffer,
	                         newSize,
	                         offset)
	when newSize < size and offset < newSize do
	{:ok, %Buffer{buffer | size: newSize}}
  end	
	
end
