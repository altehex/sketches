defmodule Tax.Terminal.State do
  alias __MODULE__, as: State
  
  alias Tax.Buffer
  alias Tax.Rect
  alias Tax.Utils.Termios
  alias Tax.Utils.Unistd

  require Logger

  # no glowies were involved
  use Agent


  @type arg_list :: Keyword.t
  @type display_types :: :fullscreen | :adaptive | :fixed
  

  @type t :: %State{
	area:           Rect.t,
	capabilities:   reference,
	cursor_pos:     [x: integer, y: integer],
	display:        display_types,
	fb:             Buffer.t,
	hidden_cursor?: boolean,
	out:            atom | pid
  }
  
  defstruct [
	area:           Rect.fullscreen(),
	capabilities:   Unistd.stdin_fileno |> Termios.tcgetattr(),
	cursor_pos:     [x: 0, y: 0],
	display:        :fullscreen,
	fb:             Rect.fullscreen() |> Buffer.from_rect(),
	hidden_cursor?: false,
	out:            :stdio
  ]


  @spec start_link(arg_list) :: Agent.on_start

  def start_link([]), do:
    Agent.start_link(fn -> %State{} end, name: State)
  
  def start_link(args) do
	with area       <- Keyword.get(args, :area,       Rect.fullscreen()),
		 cursor_pos <- Keyword.get(args, :cursor_pos, [x: 0, y: 0]),
		 display    <- Keyword.get(args, :display,    :fullscreen),
	     out        <- Keyword.get(args, :out,        :stdio) do
 	  state = %State{
	     area:           area,
		 capabilities:   Unistd.stdin_fileno |> Termios.tcgetattr(),
		 cursor_pos:     cursor_pos,
	     display:        display,
		 fb:             area |> Buffer.from_rect(),
	     hidden_cursor?: args[:hidden_cursor],
		 out:            out
	  }
	  
      Agent.start_link(fn -> state end, name: State)
	end
  end
	
end


defmodule Tax.Terminal do
  alias Tax.Buffer
  alias Tax.Terminal.State

  require Logger
  
  use Supervisor


  @type agent_pid :: pid
  @type arg_list :: Keyword.t
  @type sup_pid :: pid

  
  @spec start_link(arg_list) :: {:ok, sup_pid, agent_pid}
  
  def start_link(opts \\ []) do
	with {:ok, supPid} <- Supervisor.start_link(__MODULE__, opts),
	     [{_id, agentPid, _type, _modules}] <- Supervisor.which_children(supPid) do
	  {:ok, supPid, agentPid}
	end
  end
	
  def init(args), do:
	[
      { State, start: {State, :start_link, [args]} }
	]
	|> Supervisor.init(strategy: :one_for_one)


  @spec draw(agent_pid, (Buffer.t -> Buffer.t)) :: :ok
  
  def draw(stateAgent, ui) do
	with oldFb <- get(:fb, stateAgent),
	     newFb <- ui.(oldFb),
	     :ok <- newFb |> update(:fb, stateAgent) do
	  out(newFb, stateAgent)
	end
  end
  
	
  @spec get(atom, agent_pid) :: any
  
  def get(key, stateAgent), do:
    stateAgent |> Agent.get(fn state ->
	  Map.get(state, key)
    end)
	

  @spec get_state(agent_pid) :: State.t

  def get_state(stateAgent), do:
    stateAgent |> Agent.get(fn state -> state end)


  @spec out(Buffer.t, agent_pid) :: :ok

  def out(fb, agentPid) do
	with outDevice <- get(:out, agentPid) do
	  IO.write(outDevice, fb.raw)
	end
  end
	

  @spec update(any, atom, agent_pid) :: :ok
  
  def update(value, key, stateAgent), do:
    stateAgent |> Agent.update(fn state ->
	  Map.put(state, key, value)
    end)
	
end
