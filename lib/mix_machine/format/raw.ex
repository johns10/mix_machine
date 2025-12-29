defmodule MixMachine.Format.Raw do
  @moduledoc """
  Output diagnostics in raw format matching the structure returned by `mix compile`.
  """
  @behaviour MixMachine.Format

  alias Mix.Task.Compiler.Diagnostic

  @impl true
  def render(diagnostics, opts) do
    diagnostics
    |> Enum.map(&to_map/1)
    |> Jason.encode!(pretty: opts.pretty)
  end

  defp to_map(%Diagnostic{} = diagnostic) do
    Map.from_struct(diagnostic)
  end
end
