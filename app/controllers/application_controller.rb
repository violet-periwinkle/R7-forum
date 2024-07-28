class ApplicationController < ActionController::Base
    before_action :set_current_user

private
    def set_current_user
        if session[:current_user]
            @current_user = User.find(session[:current_user])
        else
            @current_user = nil
        end
    end
end
