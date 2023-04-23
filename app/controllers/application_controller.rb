class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: :graphql_controller?

  private

  def graphql_controller?
    controller_name == 'graphql'
  end
end
