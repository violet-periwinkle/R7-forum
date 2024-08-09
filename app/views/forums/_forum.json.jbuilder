json.extract! forum, :id, :forum_name, :created_at, :updated_at
json.url forum_url(forum, format: :json)
