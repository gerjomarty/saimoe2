Saimoe2::Application.routes.draw do

  namespace :admin do
    match 'utilities', to: 'admin#utilities', via: [:get, :post]
    match 'clear-cache', to: 'admin#clear_cache', via: :get, as: :clear_cache
  end

  with_options only: [:index, :show] do |m|
    m.resources(:tournaments) do
      member do
        get 'characters_by_total_votes'
        get 'characters_by_average_votes'
        get 'series_by_total_votes'
        get 'voice_actors_by_total_votes'
        get 'rounds_by_total_votes'
        get 'rounds_by_vote_percentages'
        get 'rounds_by_series_prevalence'
        get 'rounds_by_voice_actor_prevalence'
      end
    end
    m.resources(:characters) do
      get 'autocomplete', on: :collection
    end
    m.resources(:series) do
      get 'autocomplete', on: :collection
    end
    m.resources(:voice_actors, path: 'voice-actors') do
      get 'autocomplete', on: :collection
    end
  end

  constraints year: /20\d{2}/ do
    match ':year', to: 'tournaments#show', as: :short_tournament
    match ':year/:action', controller: :tournaments, as: :short_tournament_action
  end

  constraints date: /20\d{6}/ do
    match ':date', to: 'date#show', as: :date
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
