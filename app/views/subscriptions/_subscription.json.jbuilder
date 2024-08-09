json.extract! subscription, :id, :forum_id, :user_id, :priority, :created_at, :updated_at
json.url subscription_url(subscription, format: :json)
