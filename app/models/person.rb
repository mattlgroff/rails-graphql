class Person < ApplicationRecord
  has_many :comments, dependent: :destroy
end
