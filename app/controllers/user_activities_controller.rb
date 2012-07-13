class UserActivitiesController < ApplicationController
  def index
    if (params[:year].nil? or params[:month].nil?)
      @filter_date  = Date.today
    else
      @filter_date= Date.new(params[:year].to_i, params[:month].to_i, 1)
    end
    filter_date_next = @filter_date.to_time.advance(:months => 1).to_date
   
    @activities = UserActivity
      .where(:date.gte => @filter_date)
      .where(:date.lte => filter_date_next)
      .order_by([:date, :asc])
  
    respond_to do |format|
      format.html
      format.json { render :json => @activities.map{ |a| {
          :id => a._id,
          :type => a.user_activity_type.description, 
          :date => a.date,
          :hours => a.hours,
          :description => a.description,
          :jobOrder => a.activity.job_order_code,
          :activity => a.activity.description
        }} }
    end
  end

  def create
    @activity = UserActivity.new()
    
    @activity.user_activity_type = UserActivityType.find(params[:type])
    @activity.date = DateTime.parse(params[:date])
    @activity.hours = params[:hours].to_f
    @activity.description = params[:description]
    job_order = JobOrder.find(params[:jobOrder])
    @activity.activity = job_order.activities.select{|a| a._id = params[:activity]}[0]
    @activity.user = current_user
    @activity.save

    @result = {
      :id => @activity._id,
      :type => @activity.user_activity_type.description, 
      :date => @activity.date,
      :hours => @activity.hours,
      :description => @activity.description,
      :jobOrder => job_order.code,
      :activity => @activity.activity.description
    }

    respond_to do |format|
      format.html { render :json =>  @result }
      format.json { render :json =>  @result }
    end      
  end

  def destroy
    UserActivity.find(params[:id]).delete
    respond_to do |format|
      format.html { render :json => {result: 'ok'} }
      format.json { render :json => {result: 'ok'} }
    end      
  end

end