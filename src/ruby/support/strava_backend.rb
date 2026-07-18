require 'net/http'
require 'uri'
require 'json'
require 'time'

# Minimal interface used by bin/update-runs:
#   StravaBackend.refresh_token(client_id:, client_secret:, refresh_token:)
#     -> Hash with string keys 'access_token', 'refresh_token', 'expires_at'
#   StravaBackend.activities(access_token:, after:, per_page:)
#     -> Array<StravaBackend::Activity>
module StravaBackend
  API_ENDPOINT = 'https://www.strava.com/api/v3'
  OAUTH_ENDPOINT = 'https://www.strava.com/oauth'

  Activity = Struct.new(
    :id, :name, :description, :distance, :elapsed_time, :moving_time,
    :workout_type, :total_elevation_gain, :start_date, :start_date_local,
    :sport_type, :summary_polyline,
    keyword_init: true
  )

  def self.refresh_token(client_id:, client_secret:, refresh_token:)
    uri = URI("#{OAUTH_ENDPOINT}/token")
    response = Net::HTTP.post_form(uri,
      'client_id'     => client_id,
      'client_secret' => client_secret,
      'grant_type'    => 'refresh_token',
      'refresh_token' => refresh_token
    )

    unless response.is_a?(Net::HTTPSuccess)
      raise "Strava OAuth token refresh failed: #{response.code} #{response.body}"
    end

    JSON.parse(response.body)
  end

  def self.activities(access_token:, after:, per_page:)
    uri = URI("#{API_ENDPOINT}/athlete/activities")
    uri.query = URI.encode_www_form(after: after.to_i, per_page: per_page)

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{access_token}"

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise "Strava activities request failed: #{response.code} #{response.body}"
    end

    JSON.parse(response.body).map { |a| to_activity(a) }
  end

  def self.to_activity(a)
    Activity.new(
      id: a.fetch('id'),
      name: a['name'],
      description: a['description'],
      distance: a.fetch('distance'),
      elapsed_time: a.fetch('elapsed_time'),
      moving_time: a.fetch('moving_time'),
      workout_type: a['workout_type'],
      total_elevation_gain: a.fetch('total_elevation_gain'),
      start_date: Time.parse(a.fetch('start_date')),
      # start_date_local is wall-clock local time despite the trailing "Z"
      # Strava appends to it, so strip it rather than parsing as UTC.
      start_date_local: Time.parse(a.fetch('start_date_local').sub(/Z\z/, '')),
      sport_type: a['sport_type'],
      summary_polyline: a.dig('map', 'summary_polyline')
    )
  end
  private_class_method :to_activity
end
