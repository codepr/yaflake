defmodule Yaflake.Node.Interface do
  @moduledoc false

  @callback getifaddrs() :: Keyword.t()
  def getifaddrs do
    with {:ok, ifaces} <- :inet.getifaddrs() do
      Enum.map(ifaces, fn {iface, attrs} -> {List.to_atom(iface), attrs[:hwaddr]} end)
    end
  end

  @callback getifaddr(atom()) :: [integer()]
  def getifaddr(name) do
    with ifaddrs <- getifaddrs() do
      Keyword.fetch!(ifaddrs, name)
    end
  end
end
