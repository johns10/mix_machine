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
    %{
      file: diagnostic.file,
      source: diagnostic.source,
      severity: diagnostic.severity,
      message: diagnostic.message,
      position: format_position(diagnostic.position),
      compiler_name: diagnostic.compiler_name,
      span: format_span(diagnostic.span),
      details: diagnostic.details,
      stacktrace: format_stacktrace(diagnostic.stacktrace)
    }
  end

  defp format_position(nil), do: nil
  defp format_position(line) when is_integer(line), do: line
  defp format_position({line, column}), do: %{line: line, column: column}

  defp format_span(nil), do: nil
  defp format_span({line, column}), do: %{line: line, column: column}

  defp format_stacktrace(nil), do: nil
  defp format_stacktrace([]), do: []

  defp format_stacktrace(stacktrace) when is_list(stacktrace) do
    Enum.map(stacktrace, fn
      {module, function, arity, location} when is_atom(module) ->
        %{
          module: module,
          function: function,
          arity: format_arity(arity),
          file: Keyword.get(location, :file),
          line: Keyword.get(location, :line),
          column: Keyword.get(location, :column)
        }

      {fun, arity, location} when is_function(fun) ->
        %{
          function: "(anonymous)",
          arity: format_arity(arity),
          file: Keyword.get(location, :file),
          line: Keyword.get(location, :line),
          column: Keyword.get(location, :column)
        }

      other ->
        inspect(other)
    end)
  end

  defp format_arity(arity) when is_integer(arity), do: arity
  defp format_arity(args) when is_list(args), do: length(args)
end
