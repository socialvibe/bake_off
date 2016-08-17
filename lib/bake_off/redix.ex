defmodule BakeOff.Redix do
  def command(command) do
    Redix.command(:"redix_#{random_index()}", command)
  end

  defp random_index() do
    rem(System.unique_integer([:positive]), 50) # second arg is pool size
  end
end
