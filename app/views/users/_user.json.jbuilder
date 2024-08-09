json.extract! user, :id, :name, :skill_level, :created_at, :updated_at
json.url user_url(user, format: :json)
