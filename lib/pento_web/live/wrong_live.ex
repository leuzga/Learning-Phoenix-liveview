defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    # Generar un número aleatorio al inicio y asignarlo al socket
    {:ok, assign(socket, target_number: random_number(), message: "Make a guess:", score: 0, time: time(), has_won: false)}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <h1>Guess the Number</h1>
      <h1> Your score: <%= @score %></h1>
      <%= if @has_won do %>
        <h2>
          <%= @message  %>
          It's <%= @time %>
        </h2>
        <.link href="#" phx-click="restart">
          Play Again
        </.link>
      <% else %>
        <p><%= @message %></p>
        <h2>
          <%= for n <- 1..10 do %>
            <.link href="#" phx-click="guess" phx-value-number={n}>
              <%= n %>
            </.link>
          <% end %>
        </h2>
      <% end %>
    """
  end

  defp time() do
    DateTime.utc_now() |> to_string()
  end

  defp random_number() do
    :rand.uniform(10)  # Generar un número aleatorio entre 1 y 2
  end

  @impl Phoenix.LiveView
  def handle_event("guess", %{"number" => guess}, socket) do
    guess = String.to_integer(guess)
    target_number = socket.assigns.target_number  # Número a adivinar
    score = socket.assigns.score  # Puntuación actual del usuario

    {message, new_target_number, new_score, has_won} =
      case guess do
        ^target_number ->
          # Si el guess es igual al target_number, el jugador ha ganado
          {"Your guess: #{guess}. Correct! You win! 🥇", random_number(), score + 1, true}
        _ ->
          # Si el guess no es igual al target_number, el jugador no ha acertado
          {"Your guess: #{guess}. Wrong. Try again!", target_number, score, false}
      end

    time = time()

    {:noreply, assign(socket, target_number: new_target_number, message: message, score: new_score, time: time, has_won: has_won)}
  end

  @impl Phoenix.LiveView
  def handle_event("restart", _, socket) do
    # Reiniciar el juego generando un nuevo número aleatorio
    {:noreply, assign(socket, target_number: random_number(), message: "Make a guess:", has_won: false)}
  end
end
