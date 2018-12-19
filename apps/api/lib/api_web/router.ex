defmodule ApiWeb.Router do
  use ApiWeb, :router

  @csp "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline' 'unsafe-eval'"
  if Mix.env == :dev || Mix.env == :test do
    ""
  else
    use Plug.ErrorHandler
    use Sentry.Plug
  end


  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers, %{
      "content-security-policy" => @csp
    }
    plug ApiWeb.CSPHeader
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ApiWeb do
    pipe_through :browser

    get "/", StatusController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", ApiWeb do
    pipe_through :api

    scope "/v1", V1 do
      get "/status", StatusController, :index

      #Miscellaneous
      scope "/miscellany" do
        post "/get_miscellaneous_versions", MiscellaneousController, :get_miscellaneous_versions
        post "/get_miscellaneous_version_details", MiscellaneousController, :get_miscellaneous_version_details
        post "/create_miscellaneous", MiscellaneousController, :create_miscellaneous
        post "/create_draft_miscellaneous", MiscellaneousController, :create_miscellaneous_draft
        post "/get_miscellany", MiscellaneousController, :get_miscellany
        post "/get_miscellaneous", MiscellaneousController, :get_miscellaneous
        post "/download_miscellany", MiscellaneousController, :download_miscellany
      end

      #Rooms
      scope "/rooms" do
        post "/delete_room", RoomController, :delete_room
        post "/get_rooms", RoomController, :get_rooms
        post "/get_room", RoomController, :get_room

        post "/get_room_versions", RoomController, :get_room_versions
        post "/get_room_version_details", RoomController, :get_room_version_details

        post "/create_room", RoomController, :create_room
        post "/create_draft_room", RoomController, :create_draft_room
        post "/download_rooms", RoomController, :download_rooms
        post "/update_room", RoomController, :update_room
      end


      #Diagnosis
      scope "/diagnoses" do
        post "/download_diagnoses", DiagnosisController, :download_diagnoses
        post "/get_diagnoses",  DiagnosisController, :get_diagnoses
      end

      #Procedures
      scope "/procedures" do
        post "/get_procedures", ProcedureController, :get_procedures
        post "/download_procedures", ProcedureController, :download_procedures
      end

      #Facility
      scope "/facilities" do
        post "/get_facilities", FacilityController, :get_facilities
        post "/request_facility", FacilityController, :request_facility
      end

      #Facility Groups
      scope "/facility_groups" do
        post "/create_facility_group", FacilityGroupController, :create_facility_group
        post "/get_facility_groups", FacilityGroupController, :get_facility_groups
        post "/get_facility_group", FacilityGroupController, :get_facility_group
      end

      #Packages
      scope "/packages" do
        post "/create_package", PackageController, :create_package
        post "/get_packages", PackageController, :get_packages
      post "/get_package", PackageController, :get_package
      end

      #Practitioner
      scope "/practitioners" do
        post "/get_practitioner", PractitionerController, :get_practitioner
        post "/get_practitioners", PractitionerController, :get_practitioners
      end

      #RUV
      scope "/ruvs" do
        post "/get_ruvs", RuvController, :get_ruvs
        post "/get_ruv", RuvController, :get_ruv
      end
    end
  end
end
