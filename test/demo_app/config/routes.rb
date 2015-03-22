DemoApp::Application.routes.draw do
  get '/users/:id', to: 'users#show'
end

