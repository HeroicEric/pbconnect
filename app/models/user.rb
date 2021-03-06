class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  acts_as_follower
  acts_as_followable

  has_many :updates, :dependent => :destroy

  has_many :team_memberships
  has_many :teams, :through => :team_memberships

  def feed
    Update.from_self_and_followed_by(self)
  end

  # Find the ids of given "following type" that this user is following
  #
  # following_type - type of model you want ids for
  #
  # Example:
  # @user.following_type_ids('User')
  # => [2, 5, 8, 11]
  #
  # Returns an array of integers (ids)
  def following_type_ids(following_type)
    self.follows.unblocked.for_followable_type(following_type).collect{|f| f.followable_id}
  end

  def self.not_on_team(team)
    if team.members.empty?
      User.all
    else
      User.where("id NOT IN (?)", team.member_ids)
    end
  end

  def membership_with(team)
    team_memberships.where(team_id: team.id).first
  end
end
