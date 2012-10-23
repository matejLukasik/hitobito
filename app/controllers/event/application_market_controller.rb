class Event::ApplicationMarketController < ApplicationController
  
  before_filter :authorize
  
  decorates :event, :participants, :applications, :participation
  
  helper_method :event
  
  def index
    load_participants
    load_applications
  end
  
  def add_participant
    participation.create_participant_role(event)
    event.reload
  end
  
  def remove_participant
    participation.remove_participant_role
    event.reload
  end
  
  def put_on_waiting_list
    application.update_column(:waiting_list, true)
    render 'waiting_list'
  end
  
  def remove_from_waiting_list
    application.update_column(:waiting_list, false)
    render 'waiting_list'
  end
  
  private
  
  def load_participants
    @participants = event.participations.joins(:roles).
                                         where(event_roles: {type: event.class.participant_type.sti_name}).
                                         includes(:application, :person).
                                         merge(Person.order_by_name).
                                         uniq
  end
  
  def load_applications
    filter = [1,2,3].collect { |i| "event_applications.priority_#{i}_id = ?" }.join(' OR ')
    filter << " OR event_applications.waiting_list = ?"
    
    @applications = Event::Participation.
                       includes(:application, :person).
                       where(filter, event.id, event.id, event.id, true).
                       merge(Event::Participation.pending).
                       merge(Person.order_by_name).
                       uniq
  end
  
  
  def event
    @event ||= Event.find(params[:event_id])
  end
  
  def participation
    @participation ||= Event::Participation.find(params[:id])
  end
  
  def application
    participation.application
  end
 
  def authorize
    authorize!(:application_market, event)
  end
end