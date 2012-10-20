class AddVoteGraphToMatch < ActiveRecord::Migration
  def change
    add_column :matches, :vote_graph, :string, null: true, default: nil
  end
end
