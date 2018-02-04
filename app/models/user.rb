class User < ActiveRecord::Base
  has_many :tweets

  has_secure_password

  def slug
    slug = username.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    slug
    end

  def self.find_by_slug(slug)
    all.each do |user|
      if user.slug == slug
        return user
      end
    end
  end
end
