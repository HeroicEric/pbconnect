require 'spec_helper'

describe Team do

  before(:each) do
    @attr = {
      name: "Dynasty"
    }
  end

  it "should create a new instance given a valid attribute" do
    Team.create!(@attr)
  end

  describe "validations" do
    describe "name" do
      it "requires a name" do
        team = Team.new(@attr.merge(name: ""))
        team.should_not be_valid
      end

      it "requires a name" do
        team = Factory.build(:team, name: "")
        team.should_not be_valid
      end

      it "rejects names that are too long" do
        team = Team.new(@attr.merge(name: "a"*36))
        team.should_not be_valid
      end

      it "rejects names that are too short" do
        team = Team.new(@attr.merge(name: "aa"))
        team.should_not be_valid
      end

      it "rejects names that are duplicates" do
        original_team = Factory(:team, name: "Dynasty")
        duplicate_team = Factory.build(:team, name: "Dynasty")
        duplicate_team.should_not be_valid
      end
    end
  end

  describe "associations" do
    before(:each) do @team = Factory(:team) end

    it "should have team_memberships attribute" do
      @team.should respond_to(:team_memberships)
    end

    it "should have members attribute" do
      @team.should respond_to(:members)
    end

    describe "admins" do
      it "has the admins attribute" do
        @team.should respond_to(:admins)
      end

      it "has the correct users as admins" do
        admin_user = Factory(:user)
        RosterAddition.new(team: @team, member: admin_user, role: 'admin')
        @team.admins.should include(admin_user)
      end
    end

    describe "#is_admin?" do
      before(:each) do
        @team = Factory(:team)
        @admin_user = Factory(:user)
        @non_admin_user = Factory(:user)
        RosterAddition.new(team: @team, member: @admin_user, role: 'admin')
        RosterAddition.new(team: @team, member: @non_admin_user, role: 'player')
      end

      it "returns whether or not the user is an admin of the team" do
        @team.is_admin?(@non_admin_user).should be_false
        @team.is_admin?(@admin_user).should be_true
      end
    end

    describe "#role_of" do
      it "returns the role within the team for a given user" do
        @team = Factory(:team)
        @admin_user = Factory(:user)
        @player_user = Factory(:user)
        RosterAddition.new(team: @team, member: @admin_user, role: 'admin')
        RosterAddition.new(team: @team, member: @player_user, role: 'player')
        @team.role_of(@admin_user).should == 'admin'
        @team.role_of(@player_user).should == 'player'
      end
    end
  end

end
