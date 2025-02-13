defmodule Tax.Screen do
  alias Tax.Utils.Convert
  
  
  @spec size :: [w: integer, h: integer]
  def size do
	{tputCols, 0} = System.shell("tput cols")
	{tputLines, 0} = System.shell("tput lines")
	
	with w <- tputCols
	          |> Convert.string_col_to_integer(),
		 h <- tputLines
	          |> Convert.string_col_to_integer() do
	  [w: w, h: h]
	end
  end
  
end
