require "test_helper"

class PicturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in :kevin
  end

  test "new renders a creation form without creating a leaf" do
    assert_no_changes -> { books(:handbook).leaves.count } do
      get new_book_picture_path(books(:handbook))
    end

    assert_response :success
    assert_select "form#leafable-editor[action=?][method=post]", book_pictures_path(books(:handbook), format: :html)
    assert_select "form#leafable-editor input[name=_method]", count: 0
    assert_select "nav a[href=?]", book_slug_path(books(:handbook))
  end

  test "create from an HTML form" do
    assert_difference [ "Picture.count", "Leaf.count" ], 1 do
      post book_pictures_path(books(:handbook), format: :html), params: {
        picture: {
          image: fixture_file_upload("white-rabbit.webp", "image/webp"),
          caption: "A new picture."
        }
      }
    end

    assert_response :see_other
    assert_redirected_to book_slug_path(books(:handbook))
    assert_equal "A new picture.", Picture.last.caption
    assert_equal "white-rabbit.webp", Picture.last.image.filename.to_s
    assert_equal books(:handbook), Picture.last.leaf.book
  end

  test "update picture" do
    get edit_leafable_path(leaves(:reading_picture))
    assert_response :ok

    put leafable_path(leaves(:reading_picture)), params: {
      leaf: { title: "New picture" },
      picture: {
        image: fixture_file_upload("white-rabbit.webp", "image/webp")
      } }

    assert_response :no_content

    updated_picture = Picture.last
    assert_equal "New picture", updated_picture.title
    assert_equal "white-rabbit.webp", updated_picture.image.filename.to_s
  end

  test "update caption" do
    get edit_leafable_path(leaves(:reading_picture))
    assert_response :ok

    put leafable_path(leaves(:reading_picture)), params: {
      picture: {
        caption: "New caption"
      } }

    assert_response :no_content

    updated_picture = Picture.last

    assert_equal "New caption", updated_picture.caption
    assert_equal "reading.webp", updated_picture.image.filename.to_s
  end
end
