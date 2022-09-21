defmodule Macvendors.Macvendors do
  def load_vendors() do
    {:ok, pid} = Macvendors.Server.start_link()

    [
      {"mal", "https://standards-oui.ieee.org/oui/oui.csv"},
      {"mam", "https://standards-oui.ieee.org/oui28/mam.csv"},
      {"mas", "https://standards-oui.ieee.org/oui36/oui36.csv"}
    ]
    |> Enum.each(&load_registry(&1, pid))
    pid
  end

  def load_registry({registry, url}, pid) do
    url
    |> download
    |> save(registry)
    |> load(pid)
  end

  def download(url) do
    IO.puts "Downloading #{url}..."
    %HTTPoison.Response{body: body} = HTTPoison.get!(url)
    body
  end

  def save(body, registry) do
    path = "/tmp/#{registry}.csv"
    IO.puts "Saving #{registry} to #{path}"
    File.write!(path, body)
    path
  end

  def load(path, pid) do
    IO.puts "Loading #{path}..."

    path
    |> File.stream!
    |> CSV.decode!(
         strip_fields: true,
         headers: true
       )
    |> Enum.each(fn(vendor) -> Macvendors.Server.add(pid, vendor) end)

    pid
  end
end