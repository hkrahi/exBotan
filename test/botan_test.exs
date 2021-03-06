defmodule BotanTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  doctest Botan
  alias Botan.Model.{Result, Error}

  setup_all do
    HTTPoison.start
  end

  test "event is tracked" do
    use_cassette "perfect_working_cassette" do
      response = Botan.track("/hello", 13, additional_param: "Gabba Gabba Hey!")
      assert {:ok, %Result{status: "accepted"}} == response
    end
  end

  test "empty token" do
    use_cassette "empty_token" do
      response = Botan.track("/awesome_event", 13)
      assert {:error, %Error{reason: "token required", code: 400}} == response
    end
  end

  test "empty event name" do
    use_cassette "empty_event_name" do
      response = Botan.track("", 13)
      assert {:error, %Error{reason: "name required", code: 400}} == response
    end
  end

  test "request error" do
    use_cassette "connection_problem" do
      response = Botan.track("/awesome_event", 13)
      assert {:error, %Error{reason: "nxdomain"}} == response ||
        {:error, %Error{reason: :nxdomain}} == response
    end
  end
end
