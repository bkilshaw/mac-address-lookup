defmodule Macvendors.Server do
  use GenServer

  # Client
  def start_link() do
    GenServer.start_link(__MODULE__, %{})
  end

  def add(pid, vendor) do
    GenServer.cast(pid, vendor)
  end

  def find(pid, prefix) do
    GenServer.call(pid, {:find, prefix})
  end

  # Server
  def init(arg) do
    {:ok, arg}
  end

  def handle_cast(%{"Assignment" => assignment} = vendor, vendors) do
    updated_vendors = Map.put(vendors, assignment, vendor)
    {:noreply, updated_vendors}
  end

  def handle_call({:find, prefix}, _from, vendors) do
    results = case Map.fetch(vendors, prefix) do
      {:ok, vendor} -> vendor
      :error -> "Not Found"
    end
    {:reply, results, vendors}
  end
end