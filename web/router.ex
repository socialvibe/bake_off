defmodule BakeOff.Router do
  use BakeOff.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BakeOff do
    pipe_through :browser # Use the default browser stack

    #temporarily all GETs for testing
    get "/pies", PieController, :index
    get "/pies/recommend", PieController, :recommend
    get "/pie/:pie_id", PieController, :show
    post "/pie/:pie_id/purchases", PieController, :purchases
    get "/*path", PageController, :not_found
  end

  #Other scopes may use custom stacks.
  scope "/api", BakeOff do
    pipe_through :api

    get "/pies/:pie_id", PieController, :show
  end
end
