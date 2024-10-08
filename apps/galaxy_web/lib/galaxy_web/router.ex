defmodule GalaxyWeb.Router do
  use GalaxyWeb, :router

  import GalaxyWeb.Auth, only: [authenticate_user: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GalaxyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug GalaxyWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GalaxyWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/users", UserController, :index
    get "/users/new", UserController, :new
    post "/users", UserController, :create
    get "/users/:id/edit", UserController, :edit
    put "/users/:id", UserController, :update
    get "/users/:id/", UserController, :show
    delete "/users/:id", UserController, :delete
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/watch/:id", WatchController, :show
    resources "/annotations", AnnotationController, only: [:create]
  end

  scope "/", GalaxyWeb do
    pipe_through [:browser, :authenticate_user]

    resources "/videos", VideoController
  end

  scope "/manage", GalaxyWeb do
    pipe_through [:browser, :authenticate_user]

    resources "/videos", VideoController
  end
  # Other scopes may use custom stacks.
  # scope "/api", GalaxyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:galaxy, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GalaxyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
