defmodule Data.Factory do
  @moduledoc "All mock data used for testing are defined here"
  use ExMachina.Ecto, repo: Data.Repo

  alias Data.Schemas.{
    Diagnosis,
    Facility,
    FacilityGroup,
    GenericLookUp,
    Miscellaneous,
    MiscellaneousArchive,
    Procedure,
    Region,
    FacilityRoom,
    RoomArchive,
    Room,
    RoomArchive,
    Sequence,
    Package,
    Practitioner,
    PractitionerPhone,
    PractitionerCorporate,
    PractitionerCorporateSchedule,
    PractitionerPrimary,
    PractitionerPrimaryRoom,
    PractitionerPrimarySpecialization,
    PractitionerPrimarySchedule,
    AddressLookUp,
    Coverage,
    Ruv,
    RuvMultiplier
  }

  def room_factory do
    %Room{}
  end

  def room_archive_factory do
    %RoomArchive{}
  end

  def practitioners_factory do
    %Practitioner{}
  end

  def diagnosis_factory do
    %Diagnosis{}
  end

  def procedure_factory do
    %Procedure{}
  end

  def miscellaneous_factory do
    %Miscellaneous{}
  end

  def miscellaneous_archive_factory do
    %MiscellaneousArchive{}
  end

  def region_factory do
    %Region{}
  end

  def facility_room_factory do
    %FacilityRoom{}
  end

  def facility_factory do
    %Facility{}
  end

  def facility_group_factory do
    %FacilityGroup{}
  end

  def generic_look_up_factory do
    %GenericLookUp{}
  end

  def sequence_factory do
    %Sequence{}
  end

  def package_factory do
    %Package{}
  end

  def practitioner_factory do
    %Practitioner{}
  end

  def practitioner_phone_factory do
    %PractitionerPhone{}
  end

  def practitioner_corporate_factory do
    %PractitionerCorporate{}
  end

  def practitioner_corporate_schedule_factory do
    %PractitionerCorporateSchedule{}
  end

  def practitioner_primary_factory do
    %PractitionerPrimary{}
  end

  def practitioner_primary_room_factory do
    %PractitionerPrimaryRoom{}
  end

  def practitioner_primary_specialization_factory do
    %PractitionerPrimarySpecialization{}
  end

  def practitioner_primary_schedule_factory do
    %PractitionerPrimarySchedule{}
  end

  def address_look_up_factory do
    %AddressLookUp{}
  end

  def coverage_factory do
    %Coverage{}
  end

  def ruv_factory do
    %Ruv{}
  end

  def ruv_multipliers_factory do
    %RuvMultiplier{}
  end

end
