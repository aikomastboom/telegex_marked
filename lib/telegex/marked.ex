defmodule Telegex.Marked do
  @moduledoc """
  Safe Markdown parser/renderer for Telegram.
  """

  @typedoc "The node tree that makes up the document."
  @type document :: [[Telegex.Marked.Node.t()]]

  alias Telegex.Marked.{BlockParser, HTMLRenderer}

  @doc """
  Convert Markdown text to HTML text.

  ## Examples
      iex> Telegex.Marked.as_html("hello")
      "hello"

  Note: The current `options` parameter is reserved and has no practical meaning.
  """
  @spec as_html(String.t()) :: String.t()
  def as_html(markdown, _options \\ []) do
    markdown |> replace_raw_enscape() |> BlockParser.parse() |> HTMLRenderer.render()
  end

  # Temporary solution: replace the real escape character (that is \\) with another string to resolve issue#9
  defp replace_raw_enscape(text) do
    String.replace(text, ~S"\\", ~S"ˇescapeˇ")
  end

  @doc ~S"""
  Escape the Markdown markups contained in the text.

  ## Examples
      iex> Telegex.Marked.escape_text("*_~[]()`\\")
      ~S"\*\_\~\[\]\(\)\`\\"

  Note: The current options parameter is reserved and has no practical meaning.
  """
  @spec escape_text(String.t(), keyword()) :: String.t()
  def escape_text(text, _options \\ []) do
    String.replace(text, ~r/(\*|_|~|\[|\]|\(|\)|`|\\)/, "\\\\\\g{1}")
  end
end
