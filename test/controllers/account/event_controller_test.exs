defmodule Classlab.Account.EventControllerTest do
  alias Classlab.Event
  use Classlab.ConnCase

  @valid_attrs Factory.params_for(:event) |> Map.take(~w[public slug name description starts_at ends_at timezone]a)

  @invalid_attrs %{public: ""}
  @form_field "event_name"

  setup %{conn: conn} do
    user = Factory.insert(:user)
    {:ok, conn: Session.login(conn, user)}
  end

  test "#index lists all entries on index", %{conn: conn} do
    event = Factory.insert(:event)
    conn = get conn, account_event_path(conn, :index)
    assert html_response(conn, 200) =~ event.name
  end

  test "#new renders form for new resources", %{conn: conn} do
    conn = get conn, account_event_path(conn, :new)
    assert html_response(conn, 200) =~ @form_field
  end

  test "#create creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, account_event_path(conn, :create), event: Map.put(@valid_attrs, :location, Factory.params_for(:location))
    assert redirected_to(conn) == account_event_path(conn, :index)
    assert Repo.get_by(Event, @valid_attrs)
  end

  test "#create does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, account_event_path(conn, :create), event: @invalid_attrs
    assert html_response(conn, 200) =~ @form_field
  end

  test "#show shows chosen resource", %{conn: conn} do
    event = Factory.insert(:event)
    conn = get conn, account_event_path(conn, :show, event)
    assert html_response(conn, 200) =~ event.name
  end

  test "#show renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, account_event_path(conn, :show, -1)
    end
  end

  test "#edit renders form for editing chosen resource", %{conn: conn} do
    event = Factory.insert(:event)
    conn = get conn, account_event_path(conn, :edit, event)
    assert html_response(conn, 200) =~ @form_field
  end

  test "#update updates chosen resource and redirects when data is valid", %{conn: conn} do
    event = Factory.insert(:event)
    conn = put conn, account_event_path(conn, :update, event), event: @valid_attrs
    assert redirected_to(conn) == account_event_path(conn, :show, @valid_attrs.slug)
    assert Repo.get_by(Event, @valid_attrs)
  end

  test "#update does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    event = Factory.insert(:event)
    conn = put conn, account_event_path(conn, :update, event), event: @invalid_attrs
    assert html_response(conn, 200) =~ @form_field
  end

  test "#delete deletes chosen resource", %{conn: conn} do
    event = Factory.insert(:event)
    conn = delete conn, account_event_path(conn, :delete, event)
    assert redirected_to(conn) == account_event_path(conn, :index)
    refute Repo.get(Event, event.id)
  end
end