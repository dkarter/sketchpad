defmodule Sketchpad.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "pad:*", Sketchpad.PadChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket, 
    check_origin: ["//localhost", "//127.0.0.1", "//example.com"]
    # Dorian: ^ for apps in production use check_origin and add the domain 
  # Dorian: don't use that : v
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  def connect(%{"token" => token}, socket) do
    IO.puts "Connect -----------"
                                                                      # two
                                                                      # weeks
    case Phoenix.Token.verify(socket, "crazy random salt", token, max_age: 1209600) do
      {:ok, user_id} ->
        IO.puts "ws: verified"
        {:ok, assign(socket, :user_id, user_id)}
      {:error,_reason} -> 
        IO.puts "ws: DENIED"
        :error
    end
    # {:ok, socket}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Sketchpad.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
