class HostsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]

  def unsubscribe
    @host = Host.find(params[:id])
    current_user.toggle_flag(@host, :unsubscribe) #toggle :unsubscribe flag via flaggable gem

    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
end