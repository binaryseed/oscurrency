# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  ## Menu helpers
  
  def menu
    home     = menu_element("home",   home_path)
    categories = menu_element("SkillBank", categories_path)
    people   = menu_element("friends", people_path)
    if Forum.count == 1
      forum = menu_element("forum", forum_path(Forum.find(:first)))
    else
      forum = menu_element("forums", forums_path)
    end
    # resources = menu_element("Resources", "http://docs.insoshi.com/")
    if logged_in? and not admin_view?
      profile  = menu_element("profile",  person_path(current_person))
      offers = menu_element("Offers", offers_path)
      requests = menu_element("Requests", reqs_path)
      messages = menu_element("inbox", messages_path)
      # blog     = menu_element("Blog",     blog_path(admin.blog))
      # photos   = menu_element("Photos",   photos_path)
#      contacts = menu_element("Contacts",
#                              person_connections_path(current_person))
#      links = [home, profile, contacts, messages, blog, people, forum]
      events   = menu_element("events", events_path)
      links = [ profile, people, categories, offers, requests, messages, forum, events]

      
    elsif logged_in? and admin_view?
      home =    menu_element("Home", home_path)
      spam = menu_element("Spam", admin_broadcast_emails_path)
      people =  menu_element("People", admin_people_path)
      forums =  menu_element(inflect("forum", Forum.count),
                             admin_forums_path)
      preferences = menu_element("Prefs", admin_preferences_path)
      links = [home, spam, people, forums, preferences]
    else
      #links = [home, people]
      login =    menu_element("home", home_path)
      signup =    menu_element("signup", signup_path)
      links = [login]
      if !global_prefs.questions.blank?
        links.push(menu_element("Community Currency Primer", questions_url))
      end
      if !global_prefs.about.blank?
        links.push(menu_element("How CEC Works", about_url))
      end
      if !global_prefs.memberships.blank?
        links.push(menu_element("Membership Guidelines", memberships_url))
      end
      if !global_prefs.practice.blank?
        links.push(menu_element("Practice", practice_url))
      end
      if !global_prefs.steps.blank?
        links.push(menu_element("Steps", steps_url))
      end
      if !global_prefs.contact.blank?
        links.push(menu_element("Contact", contact_url))
      end
      links.push(categories)
      links.push(signup)
    end

    links
  end
  
  def menu_element(content, address)
    { :content => content, :href => address }
  end
  
  def menu_link_to(link, options = {})
    link_to(link[:content], link[:href], options)
  end
  
  def menu_li(link, options = {})
    klass = "n-#{link[:content].downcase}"
    klass += " active" if current_page?(link[:href])
    content_tag(:li, menu_link_to(link, options), :class => klass)
  end
  
  # Return true if the user is viewing the site in admin view.
  def admin_view?
    params[:controller] =~ /admin/ and admin?
  end
  
  def admin?
    logged_in? and current_person.admin?
  end
  
  # Set the input focus for a specific id
  # Usage: <%= set_focus_to 'form_field_label' %>
  def set_focus_to(id)
    javascript_tag("$('#{id}').focus()");
  end
 
  # Same as Rails' simple_format helper without using paragraphs
  def simple_format_without_paragraph(text)
    text.to_s.
      gsub(/\r\n?/, "\n").                    # \r\n and \r -> \n
      gsub(/\n\n+/, "<br /><br />").          # 2+ newline  -> 2 br
      gsub(/([^\n]\n)(?=[^\n])/, '\1<br />')  # 1 newline   -> br
  end

  # Display text by sanitizing and formatting.
  # The html_options, if present, allow the syntax
  #  display("foo", :class => "bar")
  #  => '<p class="bar">foo</p>'
  def display(text, html_options = nil)
    begin
      if html_options
        html_options = html_options.stringify_keys
        tag_opts = tag_options(html_options)
      else
        tag_opts = nil
      end
      processed_text = format(sanitize(text))
    rescue
      # Sometimes Markdown throws exceptions, so rescue gracefully.
      processed_text = content_tag(:p, sanitize(text))
    end
    add_tag_options(processed_text, tag_opts)
  end
  
  # Output a column div.
  # The current two-column layout has primary & secondary columns.
  # The options hash is handled so that the caller can pass options to 
  # content_tag.
  # The LEFT, RIGHT, and FULL constants are defined in 
  # config/initializers/global_constants.rb
  def column_div(options = {}, &block)
    klass = options.delete(:type) == :primary ? "col1" : "col2"
    # Allow callers to pass in additional classes.
    options[:class] = "#{klass} #{options[:class]}".strip
    content = content_tag(:div, capture(&block), options)
    concat(content, block.binding)
  end

  def volume_link(person, options = {})
    path = person_path(person)
    img = image_tag("icons/bargraph.gif")
    action = "Net Activity: <em>#{person.net_activity} marbles</em>"
    opts = {}
    str = link_to(img,path, opts)
    str << "&nbsp;"
    str << link_to_unless_current(action, path, opts)
  end

  def account_link(person, options = {})
    path = person_path(person) # XXX link to transactions
    img = image_tag("icons/shopping_cart.gif")
    action = "Balance: <em>#{person.account.balance} marbles</em>"
    opts = {}
    str = link_to(img,path, opts)
    str << "&nbsp;"
    str << link_to_unless_current(action, path, opts)
  end

  def exchange_link(person, options = {})
    img = image_tag("icons/switch.gif")
    path = new_person_exchange_path(person)
    opts = {}
    action = "Transfer Gift Marbles"
    str = link_to(img,path,opts)
    str << "&nbsp;"
    str << link_to_unless_current(action, path, opts)
  end

  def email_link(person, options = {})
    reply = options[:replying_to]
    if reply
      path = reply_message_path(reply)
    else
      path = new_person_message_path(person)
    end
    img = image_tag("icons/email.gif")
    action = reply.nil? ? "Send a message" : "Send reply"
    opts = { :class => 'email-link' }
    str = link_to(img, path, opts)
    str << "&nbsp;"
    str << link_to_unless_current(action, path, opts)
  end

  # Return a formatting note (depends on the presence of a Markdown library)
  def formatting_note
    if markdown?
      "<p class='formatting'><span>Formatting markup</span><br /> *<em>italic</em>* **<strong>bold</strong>** <br /> [Link Text](http://link_url) <br /> > quote <br /> + list </p>" 
    else 
      " "
    end
  end

def relative_time_ago_in_words(time)
  if time > Time.now
  "in " + time_ago_in_words(time)
  else
    time_ago_in_words(time) + " ago"
  end
end

# YUI
def yui_headers(textspace)  
    @yui_head = capture do
         content_for(:head) {'           
        <!-- Combo-handled YUI CSS files: -->
        <link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/combo?2.6.0/build/assets/skins/sam/skin.css">
        <!-- Combo-handled YUI JS files: -->
        <script type="text/javascript" src="http://yui.yahooapis.com/combo?2.6.0/build/yahoo-dom-event/yahoo-dom-event.js&2.6.0/build/container/container_core-min.js&2.6.0/build/menu/menu-min.js&2.6.0/build/element/element-beta-min.js&2.6.0/build/button/button-min.js&2.6.0/build/editor/editor-min.js"></script>
'}
  end
  yui_rte(textspace)  
end

def yui_headers_debug(textspace) 
    @yui_head = capture do
         content_for(:head) {'           
           <!-- Combo-handled YUI CSS files: -->
           <link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/combo?2.6.0/build/menu/assets/skins/sam/menu.css&2.6.0/build/button/assets/skins/sam/button.css&2.6.0/build/editor/assets/skins/sam/editor.css&2.6.0/build/logger/assets/skins/sam/logger.css">
           <!-- Combo-handled YUI JS files: -->
           <script type="text/javascript" src="http://yui.yahooapis.com/combo?2.6.0/build/yahoo/yahoo-debug.js&2.6.0/build/dom/dom-debug.js&2.6.0/build/event/event-debug.js&2.6.0/build/container/container_core-debug.js&2.6.0/build/menu/menu-debug.js&2.6.0/build/element/element-beta-debug.js&2.6.0/build/button/button-debug.js&2.6.0/build/editor/editor-debug.js&2.6.0/build/logger/logger-debug.js"></script>
'}
  end
  yui_rte(textspace)  
end

def yui_headers_raw(textspace) 
    @yui_head = capture do
         content_for(:head) {'           
           <!-- Combo-handled YUI CSS files: -->
           <link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/combo?2.6.0/build/menu/assets/skins/sam/menu.css&2.6.0/build/button/assets/skins/sam/button.css&2.6.0/build/editor/assets/skins/sam/editor.css">
           <!-- Combo-handled YUI JS files: -->
           <script type="text/javascript" src="http://yui.yahooapis.com/combo?2.6.0/build/yahoo/yahoo.js&2.6.0/build/dom/dom.js&2.6.0/build/event/event.js&2.6.0/build/container/container_core.js&2.6.0/build/menu/menu.js&2.6.0/build/element/element-beta.js&2.6.0/build/button/button.js&2.6.0/build/editor/editor.js"></script>
'}
  end
  yui_rte(textspace)  
end

def yui_rte(textspace) 
      @yui_text = capture do
         content_for(:yui_rte) {'           
           <script type="text/javascript">
           var myEditor = new YAHOO.widget.Editor("' + textspace + '", {
               handleSubmit: true,
               dompath: false, //Turns on the bar at the bottom
               animate: true, //Animates the opening, closing and moving of Editor windows
               collapse: true,
               titlebar: "This is text",
               draggable: false,
               buttons: [
                         { group: "fontstyle", label: "Font Name and Size",
                             buttons: [
                                 { type: "select", label: "Arial", value: "fontname", disabled: true,
                                     menu: [
                                         { text: "Arial", checked: true },
                                         { text: "Arial Black" },
                                         { text: "Comic Sans MS" },
                                         { text: "Courier New" },
                                         { text: "Lucida Console" },
                                         { text: "Tahoma" },
                                         { text: "Times New Roman" },
                                         { text: "Trebuchet MS" },
                                         { text: "Verdana" }
                             ]
                           },
                           { type: "spin", label: "13", value: "fontsize", range: [ 9, 75 ], disabled: true }
                       ]
                   },
                   { type: "separator" },
                   { group: "textstyle", label: "Font Style",
                       buttons: [
                           { type: "push", label: "Bold CTRL + SHIFT + B", value: "bold" },
                           { type: "push", label: "Italic CTRL + SHIFT + I", value: "italic" },
                           { type: "push", label: "Underline CTRL + SHIFT + U", value: "underline" },
                           { type: "separator" },
                           { type: "color", label: "Font Color", value: "forecolor", disabled: true },
                           { type: "color", label: "Background Color", value: "backcolor", disabled: true }
                       ]
                   },
                   { type: "separator" },
                   { group: "indentlist", label: "Lists",
                       buttons: [
                           { type: "push", label: "Create an Unordered List", value: "insertunorderedlist" },
                           { type: "push", label: "Create an Ordered List", value: "insertorderedlist" }
                       ]
                   },
                   { type: "separator" },
                   { group: "insertitem", label: "Insert Item",
                       buttons: [
                           { type: "push", label: "HTML Link CTRL + SHIFT + L", value: "createlink", disabled: true },
                           { type: "push", label: "Insert Image", value: "insertimage" }
                       ]
                   }
               ]
               
           });
           myEditor.render();
           </script>
'}
  end

end

  private
  
    def inflect(word, number)
      number > 1 ? word.pluralize : word
    end
    
    def add_tag_options(text, options)
      text.gsub("<p>", "<p#{options}>")
    end
    
    # Format text using BlueCloth (or RDiscount) if available.
    def format(text)
      if text.nil?
        ""
      elsif defined?(RDiscount)
        RDiscount.new(text).to_html
      elsif defined?(BlueCloth)
        BlueCloth.new(text).to_html
      elsif no_paragraph_tag?(text)
        content_tag :p, text
      else
        text
      end
    end
    
    # Is a Markdown library present?
    def markdown?
      defined?(RDiscount) or defined?(BlueCloth)
    end
    
    def shorten(str,len=50)
      if str
        if str.length>50
          str.slice(0,len).gsub(/(\s\S+)$/,"").strip.concat("...")
        else 
          str
        end
      else 
        ""
      end
    end
    
    # Return true if the text *doesn't* start with a paragraph tag.
    def no_paragraph_tag?(text)
      text !~ /^\<p/
    end
end
