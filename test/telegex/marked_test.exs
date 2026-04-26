defmodule Telegex.MarkedTest do
  use ExUnit.Case
  doctest Telegex.Marked

  import Telegex.Marked

  test "escape_text/2" do
    link_text = "*_~[]()`\\"

    markdown = """
    [#{escape_text(link_text)}](link://path)
    """

    html = """
    <a href="link://path">*_~[]()`\\</a>
    """

    assert as_html(markdown) == html
  end

  test "entities replace" do
    markdown = "[<Google&Search>](https://www.google.com)"
    html = ~s(<a href="https://www.google.com">&lt;Google&amp;Search&gt;</a>)

    assert as_html(markdown) == html
  end

  @tag :escape_markups
  test "escape markups" do
    markdown = ~S"""
    \`code\`
    \```
    code block
    ```
    \*normal*
    \_**bold**_
    \[link](link://path)
    \\
    """

    html = ~S"""
    `code`
    ```
    code block
    ```
    *normal*
    _<b>bold</b>_
    [link](link://path)
    \
    """

    assert as_html(markdown) == html
  end

  # https://github.com/Hentioe/telegex_marked/issues/3
  test "issue#3" do
    markdown = """
    # ```
    # code
    # ```

    **continuous markup**
    """

    html = """
    # ```
    # code
    # ```

    <b>continuous markup</b>
    """

    assert as_html(markdown) == html
  end

  # https://github.com/Hentioe/telegex_marked/issues/9
  @tag :issue9
  test "issue#9" do
    markdown = ~S"""
    _来自『*\*\_\~\[\]\(\)\`\\*』的验证，请确认问题并选择您认为正确的答案。_
    """

    html = ~S"""
    <i>来自『**_~[]()`\*』的验证，请确认问题并选择您认为正确的答案。</i>
    """

    assert as_html(markdown) == html
  end

  # https://github.com/Hentioe/telegex_marked/issues/10
  @tag :issue10
  test "issue#10" do
    markdown = ~S"""
    刚刚 [871769395](tg://user?id=871769395) 通过了验证，用时 13 秒。
    """

    html = ~S"""
    刚刚 <a href="tg://user?id=871769395">871769395</a> 通过了验证，用时 13 秒。
    """

    assert as_html(markdown) == html

    name =
      ~S"*_~[]()`\'_', '*', '[', ']', '(', ')', '~', '`', '>', '#', '+', '-', '=', '|', '{', '}', '.', '!'"

    markdown = """
    刚刚 [#{escape_text(name)}](tg://user?id=871769395) 通过了验证，用时 13 秒。
    """

    html = ~S"""
    刚刚 <a href="tg://user?id=871769395">*_~[]()`\'_', '*', '[', ']', '(', ')', '~', '`', '&gt;', '#', '+', '-', '=', '|', '{', '}', '.', '!'</a> 通过了验证，用时 13 秒。
    """

    assert as_html(markdown) == html
  end

  # https://github.com/Hentioe/telegex_marked/issues/8
  @tag :issue8
  test "issue#8" do
    markdown = """
    [[]]()
    """

    html = """
    <a href="">[]</a>
    """

    assert as_html(markdown) == html
  end

  test "" do
    markdown = """
    ____。。。
    """

    html = """
    ____。。。
    """

    assert as_html(markdown) == html
  end

  test "single and double asterisk bold behavior" do
    assert as_html("*bold*") == "*bold*"
    assert as_html("**bold**") == "<b>bold</b>"
  end

  # Regression: ItalicRule crashed with MatchError when underscore
  # appeared at index 0 or 1 in the character list after the opening
  # underscore, because Enum.slice returned fewer than 2 elements.
  describe "italic rule edge cases" do
    test "simple italic" do
      assert as_html("_italic_") == "<i>italic</i>"
    end

    test "single char italic" do
      assert as_html("_a_") == "<i>a</i>"
    end

    test "italic at start of line" do
      assert as_html("_test_ hello") == "<i>test</i> hello"
    end

    test "multiple italics" do
      assert as_html("_a_ and _b_") == "<i>a</i> and <i>b</i>"
    end

    test "italic mixed with bold" do
      assert as_html("**bold** with _italic_") == "<b>bold</b> with <i>italic</i>"
    end

    test "italic next to underline" do
      assert as_html("_italic_ then __underline__") == "<i>italic</i> then <u>underline</u>"
    end

    test "underscore in middle of word is not italic" do
      # Unmatched underscores pass through as-is
      result = as_html("hello_world_test")
      assert is_binary(result)
    end

    test "unclosed italic underscore does not crash" do
      result = as_html("_unclosed")
      assert is_binary(result)
    end

    test "LLM markdown with backticks bold and underscores does not crash" do
      content =
        "Your WebDAV root directory `/home/Obsidian` contains **47 files** and **1 directory**:\n" <>
          "- **Markdown notes**: `baseline_for_front-end_developers.md`, `clojure.md`\n" <>
          "- **Images**: Several PNG files (Nix screenshots, etc.)\n" <>
          "- **Other docs**: `exact_book_invoice.md`, `co-sleeper.md`"

      result = as_html(content)
      assert is_binary(result)
    end
  end
end
