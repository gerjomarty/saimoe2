class Appearance < ActiveRecord::Base
  attr_accessible :character_display_name, :character_role, :tournament

  mount_uploader :character_avatar, AvatarUploader

  belongs_to :character_role, inverse_of: :appearances
  belongs_to :tournament, inverse_of: :appearances
  has_many :match_entries, inverse_of: :appearance
  has_many :voice_actor_roles, inverse_of: :appearance

  validates :character_role_id, :tournament_id, presence: true
  validate :one_appearance_per_tournament

  private

  def one_appearance_per_tournament
    apps = Appearance.joins(:character_role)
                     .where(character_roles: {character_id: character_role && character_role.character_id})
    if apps.any? {|app| app.id != self.id && app.tournament_id == self.tournament_id}
      errors.add :base, "Character can only appear once per tournament"
    end
  end
end
