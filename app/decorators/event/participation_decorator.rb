# encoding: utf-8
class Event::ParticipationDecorator < ApplicationDecorator
  decorates 'event/participation'
  
  decorates_association :person
  decorates_association :event
  decorates_association :application
  
  delegate :to_s, :email, :all_phone_numbers, :complete_address, :all_social_accounts, to: :person
  
  # render a list of all participations
  def roles_short(event)
    h.safe_join(roles) do |r|
      content_tag(:p, r)
    end
  end

  def application_contact
    if application && application.contact 
      klass = application.contact.class.base_class
      decorator = "#{klass}Decorator".constantize.decorate(application.contact)
      h.render 'contactable/show', contactable: decorator, only_public: true
    end
  end

  def flash_info
    "von <i>#{h.h(person)}</i> in <i>#{h.h(event)}</i>".html_safe
  end
  
  def priority(event)
    if application
      prio = application.priority(event) || (application.waiting_list ? 'Warteliste' : nil)
      content_tag(:span, prio, class: 'badge') if prio
    end
  end
  
  def confirmation
    if application
      label, css, desc = if application.approved?
        %w(&#x2713; success bestätigt)
      elsif application.rejected?
        %w(&#x00D7; important abgelehnt)
      else
        %w(? warning offen)
      end
      
      content_tag(:span, label, class: "badge badge-#{css}", title: "Kursfreigabe #{desc}")
    end
  end
  
  def waiting_list_link(event)
    if application
      icon, title, method = if application.waiting_list
        ['down', 'Von der nationalen Warteliste nehmen', :delete]
      else
        ['up', 'Auf die nationale Warteliste setzen', :post]
      end
      
      h.link_to(h.icon("chevron-#{icon}"),
                h.waiting_list_event_application_market_path(event.id, id), 
                title: title, 
                remote: true, 
                method: method)
    end
  end
  
end
