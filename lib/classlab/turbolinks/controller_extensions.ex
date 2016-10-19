defmodule Classlab.Turbolinks.ControllerExtensions do
  alias Classlab.Endpoint

  def page_reload_broadcast!(args) do
    Endpoint.broadcast! "page_reload:#{Enum.join(args, ":")}", "reload", %{}
  end
end