class Location < ActiveRecord::Base
  belongs_to :user
  has_many :images
  has_many :routes


end