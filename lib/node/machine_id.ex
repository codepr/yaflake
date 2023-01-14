defmodule Yaflake.Node.MachineID do
  @moduledoc false

  @machine_id_size 10
  @iface_hwaddr_size 48

  @spec generate() :: non_neg_integer()
  def generate do
    hwaddr =
      interface_module().getifaddrs()
      |> Enum.filter(fn {_iface, addr} -> not is_nil(addr) end)
      |> Enum.map(fn {_iface, addr} -> addr end)
      |> Enum.random()

    skip_bits = @iface_hwaddr_size - @machine_id_size

    <<_skip::unsigned-integer-size(skip_bits), id::unsigned-integer-size(@machine_id_size)>> =
      :binary.list_to_bin(hwaddr)

    id
  end

  def generate(id) when is_integer(id), do: id

  def generate(id) when is_atom(id) do
    hwaddr = interface_module().getifaddr(id)
    <<_head::integer-38, id::integer-10>> = :binary.list_to_bin(hwaddr)
    id
  end

  def generate(id) when is_binary(id), do: generate(String.to_existing_atom(id))

  def generate(_) do
    raise ArgumentError,
      message: "expected an integer or a string or an atom representing a network interface"
  end

  @spec validate!(non_neg_integer()) :: :ok
  def validate!(id) when id >= 0 and id < 1024, do: :ok

  def validate!(id) do
    raise RuntimeError, "Machine ID should be an integer between 0-1023, received: #{inspect(id)}"
  end

  defp interface_module, do: Application.get_env(:yaflake, :interface_module)
end
