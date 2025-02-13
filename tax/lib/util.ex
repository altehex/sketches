defmodule Tax.Utils.Convert do

  @spec string_col_to_integer(Collectable.t) :: integer
  def string_col_to_integer(col), do:
	col
	|> String.slice(0..-2//1)
	|> String.to_integer()
  
end


defmodule Tax.Utils.Mutex do
  alias __MODULE__
  
  defstruct [locked: false]
  
  def start_link(opts \\ []) do
	GenServer.start_link(__MODULE__, opts)
  end


  def init(_opts) do
	 {:ok, %Mutex{}}
  end
  
  
  def lock(_mutex, %Mutex{locked: false}) do
	
	:ok
  end

  def unlock(_mutex, %Mutex{locked: true}) do
	:ok
  end
  
end


defmodule Tax.Utils.Termios do
  @on_load :load_nifs

  def load_nifs, do:
	:erlang.load_nif("./nif/bin/termios_nif", 0)


  @spec tcgetattr(integer) :: reference | :error
  
  def tcgetattr(_fileDesc), do:
	raise "Failed to load tcgetattr"

end 


defmodule Tax.Utils.Unistd do
  @on_load :load_nifs

  def load_nifs, do:
    :erlang.load_nif("./nif/bin/unistd_nif", 0)


  @spec isatty(integer) :: boolean | :error

  def isatty(_desc), do:
    raise "Failed to load isatty"

	
  def stdin_fileno(),  do: 0
  def stdout_fileno(), do: 1
  def stderr_fileno(), do: 2
  
end
