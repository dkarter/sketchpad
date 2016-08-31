defmodule Sketchpad.PadChannel do
  use Sketchpad.Web, :channel

  def join("pad:" <> pad_id, _params, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    # if socket.assigns.user_id == "dorian" do
    #   Process.exit(self(), :kill)
    # end
    {:noreply, socket}
  end
end
