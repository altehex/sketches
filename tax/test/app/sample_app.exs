defmodule SampleAppTest do
  use ExUnit.Case
  
  test "Tax app is correct" do
	assert Tax.run_tax_app(SampleApp) == :error
  end
  
end


defmodule SampleApp do
  @behaviour Tax.App

  def ui(parent) do
	IO.puts("ok")
	:error
  end
end
m
