defmodule Sketchpad.PadChannel do
  use Sketchpad.Web, :channel
  alias Sketchpad.Presence

  def join("pad:" <> pad_id, _params, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    %{user_id: user_id} = socket.assigns
    #private communication to client

    {:ok, _ref} = Presence.track(socket, user_id, %{device: "browser"})
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def handle_in("stroke", data, socket) do
    IO.puts "========= got stroke message"
    IO.inspect data
    # broadcast! = broadcast to everyone the new data
    # broadcast_from! = broadcast to everyone but me the new data
    
    broadcast_from!(socket, "stroke", %{
      user_id: socket.assigns.user_id,
      stroke: data,
    })
    {:reply, :ok, socket}
  end

  def handle_in("clear", data, socket) do
    IO.puts "========= got clear message"
    IO.inspect data
    # broadcast! = broadcast to everyone the new data
    # broadcast_from! = broadcast to everyone but me the new data
    
    broadcast!(socket, "clear", %{
      user_id: socket.assigns.user_id,
    })
    {:reply, :ok, socket}
  end
end
