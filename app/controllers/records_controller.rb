require 'net/ssh'
class RecordsController < ApplicationController

  before_filter :get_zone
  after_filter :reload_zone_slave, :only => [:create, :update, :destroy]
  
  def new
    @record = @zone.records.new
  end
  
  def create
    @record = @zone.send( "#{params[:record][:type].downcase}_records".to_sym ).new( params[:record] )
    if @record.save
      flash.now[:info] = "Record created!"
    else
      flash.now[:error] = "Record not created!"
      render :action => :new
    end
  end
  
  def edit
    @record = @zone.records.find( params[:id] )
  end
  
  def update
    @record = @zone.records.find( params[:id] )
    if @record.update_attributes( params[:record] )
      flash[:info] = "Record udpated!"
    else
      flash[:error] = "Record not updated!"
      render :action => :edit
    end
  end
  
  def destroy
    @record = @zone.records.find( params[:id] )
    @record.destroy
    redirect_to zone_path( @zone )
  end
  
  # Non-CRUD methods
  def update_soa
    @zone.soa_record.update_attributes( params[:soa] )
    if @zone.soa_record.valid?
      flash[:info] = "SOA record updated!"
    else
      flash[:error] = "SOA record not updated!"
    end
  end
  
  protected
  
  def get_zone
    @zone = Zone.find(params[:zone_id], :user => current_user)
  end

end
