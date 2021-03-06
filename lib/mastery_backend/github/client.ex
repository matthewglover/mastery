defmodule MasteryBackend.Github.Client do
  def start_link do
    config = Application.get_env(:mastery_backend, :github)
    Agent.start_link(fn -> Enum.into(config, %{}) end, name: __MODULE__)
  end

  def raw_token!(code) do
    payload = payload(code)
    'https://github.com/login/oauth/access_token?scope=user%20read:org'
    |> :binary.list_to_bin()
    |> HTTPoison.post(payload, [{"Content-Type", "application/json"}])
  end

  def raw_user!(token) do
    'https://api.github.com/user'
    |> :binary.list_to_bin()
    |> HTTPoison.get([{"Authorization", "Bearer #{token}"}])
  end

  defp payload(code) do
    %{client_id: id, client_secret: secret} = Agent.get(__MODULE__, &(&1))
    Poison.encode!(%{"client_id" => id, "client_secret" => secret, "code" => code})
  end

  def authorization_url() do
    %{client_id: client_id, auth_url: auth_url} = Agent.get(__MODULE__, &(&1))
    "#{auth_url}?client_id=#{client_id}&scope=user%20read:org"
  end
end
