require 'net/http'
require 'uri'
require 'json'
require 'time'

module StravaBackend
  Activity = Struct.new(
    :id, :name, :description, :distance, :elapsed_time, :moving_time,
    :workout_type, :total_elevation_gain, :start_date, :start_date_local,
    :sport_type, :summary_polyline,
    keyword_init: true
  )

  class Native
    API_ENDPOINT = 'https://www.strava.com/api/v3'
    OAUTH_ENDPOINT = 'https://www.strava.com/oauth'

    def refresh_token(client_id:, client_secret:, refresh_token:)
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

    def activities(access_token:, after:, per_page:)
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

    private

    def to_activity(a)
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
  end

  class Gem
    def refresh_token(client_id:, client_secret:, refresh_token:)
      require 'strava-ruby-client'

      client = ::Strava::OAuth::Client.new(client_id: client_id, client_secret: client_secret)
      response = client.oauth_token(refresh_token: refresh_token, grant_type: 'refresh_token')

      {
        'access_token'  => response.access_token,
        'refresh_token' => response.refresh_token,
        'expires_at'    => response.expires_at
      }
    end

    def activities(access_token:, after:, per_page:)
      require 'strava-ruby-client'

      client = ::Strava::Api::Client.new(access_token: access_token)
      client.athlete_activities(after: after, per_page: per_page).map do |a|
        Activity.new(
          id: a.id,
          name: a.name,
          description: a.description,
          distance: a.distance,
          elapsed_time: a.elapsed_time,
          moving_time: a.moving_time,
          workout_type: a.workout_type,
          total_elevation_gain: a.total_elevation_gain,
          start_date: a.start_date,
          start_date_local: a.start_date_local,
          sport_type: a.sport_type,
          summary_polyline: a.map&.summary_polyline
        )
      end
    end
  end

  def self.for(name)
    case name
    when 'native' then Native.new
    when 'gem' then Gem.new
    else raise ArgumentError, "Unknown STRAVA_BACKEND: #{name.inspect} (expected 'native' or 'gem')"
    end
  end
end
