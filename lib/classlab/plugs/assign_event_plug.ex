defmodule Classlab.AssignEventPlug do
  @moduledoc """
  Assigns the current event to the connection by checking event_id parameter.
  """
  alias Classlab.{Event, Repo}
  use Phoenix.Controller
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{assigns: %{current_event: %Event{}}} = conn, _opts), do: conn
  def call(conn, required_param) do
    unless required_param do
      raise "Missing parameter for event id key."
    end

    event_slug = conn.params[required_param]
    if event_slug do
      case Repo.get_by(Event, slug: event_slug) do
        %Event{} = event -> assign(conn, :current_event, event)
        _ ->
          conn
          |> put_flash(:error, "Ressource not found")
          |> redirect(to: "/")
          |> halt()
      end
    else
      conn
    end
  end

  def current_event(conn) do
    conn.assigns[:current_event]
  end

end
