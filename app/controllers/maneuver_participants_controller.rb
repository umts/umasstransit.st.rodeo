class ManeuverParticipantsController < ApplicationController
  before_action :find_record, only: %i(show update)
  before_action :find_maneuver_and_participant, only: :create

  def create
    deny_access && return unless current_user.has_role? :judge

    unless @participant.has_completed? @maneuver
      attrs = { maneuver: @maneuver, participant: @participant }
      attrs.merge! params.permit(:reversed_direction, :speed_achieved,
                                 :made_additional_stops, :completed_as_designed)
      attrs[:obstacles_hit] = parse_obstacles
      attrs[:distances_achieved] = parse_distance_targets
      record = ManeuverParticipant.create! attrs
    end
    redirect_to next_participant_maneuver_path(@maneuver)
    update_scoreboard with: record
  end

  def new
    @maneuver = Maneuver.find_by name: params.require(:maneuver)
    @participant = Participant.find_by number: params.require(:participant)
    @record = ManeuverParticipant.new maneuver: @maneuver,
                                      participant: @participant
  end

  def show
    @maneuver = @record.maneuver
    @participant = @record.participant
  end

  def update
    deny_access && return unless current_user.has_role? :judge
    attrs = params.permit(:reversed_direction, :speed_achieved,
                          :made_additional_stops, :completed_as_designed)
    attrs[:obstacles_hit] = parse_obstacles
    attrs[:distances_achieved] = parse_distance_targets
    @record.update! attrs
    redirect_to :back,
                notice: 'Maneuver score has been saved.'
    update_scoreboard with: @record
  end

  private

  def find_maneuver_and_participant
    @maneuver = Maneuver.find_by id: params.require(:maneuver_id)
    @participant = Participant.find_by id: params.require(:participant_id)
  end

  def find_record
    @record = ManeuverParticipant.find_by id: params.require(:id)
  end

  def parse_obstacles
    obstacles_hit = {}
    params.select do |key, value|
      key.starts_with?('obstacle') && value.to_i != 0
    end.each do |key, value|
      obstacle = Obstacle.find_by id: key.split('_').last.to_i
      obstacles_hit[obstacle.point_value] = value.to_i if obstacle.present?
    end
    obstacles_hit
  end

  def parse_distance_targets
    distances_achieved = {}
    params.select do |key, _value|
      key.starts_with?('target')
    end.each do |key, value|
      target = DistanceTarget.find_by id: key.split('_').last.to_i
      if target.present?
        distances_achieved[[target.minimum, target.multiplier]] = value.to_i
      end
    end
    distances_achieved
  end
end
