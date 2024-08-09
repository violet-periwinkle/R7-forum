class User < ApplicationRecord
    validates :skill_level, inclusion: { in: %w(beginner intermediate expert) }
end
