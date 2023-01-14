apps_to_start = [:mox]
Enum.each(apps_to_start, &Application.ensure_all_started/1)
ExUnit.start()
Mox.defmock(Yaflake.Node.InterfaceMock, for: Yaflake.Node.Interface)
Application.put_env(:yaflake, :interface_module, Yaflake.Node.InterfaceMock)
