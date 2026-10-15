require "test_helper"

class SectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in :kevin
  end

  test "new renders a creation form without creating a leaf" do
    assert_no_changes -> { books(:handbook).leaves.count } do
      get new_book_section_path(books(:handbook))
    end

    assert_response :success
    assert_select "form#leafable-editor[action=?][method=post]", book_sections_path(books(:handbook), format: :html)
    assert_select "form#leafable-editor input[name=_method]", count: 0
    assert_select "nav a[href=?]", book_slug_path(books(:handbook))
  end

  test "create" do
    post book_sections_path(books(:handbook), format: :turbo_stream)
    assert_response :success

    new_section = Section.last
    assert_equal "Section", new_section.title
    assert_equal books(:handbook), new_section.leaf.book
  end

  test "create from an HTML form" do
    assert_difference [ "Section.count", "Leaf.count" ], 1 do
      post book_sections_path(books(:handbook), format: :html), params: { section: { body: "A new section." } }
    end

    assert_response :see_other
    assert_redirected_to book_slug_path(books(:handbook))
    assert_equal "A new section.", Section.last.body
    assert_equal books(:handbook), Section.last.leaf.book
  end

  test "update" do
    put leafable_path(leaves(:welcome_section)), params: {
      leaf: { title: "Title" },
      section: { body: "Section body" }
    }
    assert_response :success

    section = leaves(:welcome_section).reload.leafable
    assert_equal "Title", section.title
    assert_equal "Section body", section.body
  end

  test "update with no body supplied" do
    put leafable_path(leaves(:welcome_section)), params: { leaf: { title: "New title" } }
    assert_response :success

    section = leaves(:welcome_section).reload.leafable
    assert_equal "New title", section.title
    assert_equal "New title", section.body
  end
end
