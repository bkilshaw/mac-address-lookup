defmodule Macvendors.Importer do
  def load_vendors() do
    [
      {"mal", "https://standards-oui.ieee.org/oui/oui.csv"},
      {"mam", "https://standards-oui.ieee.org/oui28/mam.csv"},
      {"mas", "https://standards-oui.ieee.org/oui36/oui36.csv"}
    ]
    |> Enum.each(fn list -> spawn(Macvendors.Importer, :load_registry, [list]) end)
  end

  def load_registry({registry, url}) do
    url
    |> download
    |> save(registry)
    |> load
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

  def load(path) do
    IO.puts "Loading #{path}..."

    path
    |> File.stream!
    |> CSV.decode!(
         strip_fields: true,
         headers: true
       )
    |> Enum.each(fn(vendor) -> Macvendors.Server.add(vendor) end)

  end
end