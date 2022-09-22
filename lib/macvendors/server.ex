defmodule Macvendors.Server do
  use GenServer

  # Client
  def start_link(_arts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add(vendor) do
    GenServer.cast(__MODULE__, vendor)
  end

  def lookup(prefix) do    
    GenServer.call(__MODULE__, {:lookup, prefix})
  end

  # Server
  def init(arg) do
    Macvendors.Importer.load_vendors()
    {:ok, arg}
  end

  def handle_cast(%{"Assignment" => assignment} = vendor, vendors) do
    updated_vendors = Map.put(vendors, assignment, vendor)
    {:noreply, updated_vendors}
  end

  def handle_call({:lookup, prefix}, _from, vendors) do
    prefix
      |> String.replace(~r/[^a-zA-Z0-9]*/, "")
      |> String.upcase()
      |> String.slice(0, 9)

    results = lookup(prefix, vendors)
  
    {:reply, results, vendors}
  end

  def lookup(prefix, vendors) when is_binary(prefix) do  
    results = case Map.fetch(vendors, prefix) do
      {:ok, vendor} -> vendor
      :error -> lookup(next_prefix(prefix), vendors)
    end

    results
  end

  def lookup(_prefix, _vendors), do: "Not Found"

  def next_prefix(prefix) when is_binary(prefix) do
    cond do
      String.length(prefix) > 9 -> String.slice(prefix, 0, 9)
      String.length(prefix) >= 8 -> String.slice(prefix, 0, 7)
      String.length(prefix) === 7 -> String.slice(prefix, 0, 6)
      true -> :invalid
    end
  end

  def next_prefix(_prefix), do: :invalid
  

end