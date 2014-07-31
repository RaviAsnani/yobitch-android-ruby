require "app/boot"

java_import 'android.provider.ContactsContract'


# Handles the contacts syncing - currently only the email id's present in the user's raw contacts. 
# Nothing else
# All actions are async in nature
class ContactsSync
  include Net
  
  attr_accessor :context, :auth_token

  def initialize(context, auth_token)
    @context = context
    @auth_token = auth_token
  end



  # Does the heavy lifting of syncing user's contacts on server
  def sync
    Logger.d("Sync invoked for ContactsSync")
    find_all_contacts_with_email { |emails|
      Logger.d("Going to sync #{emails.length} contacts")
      # Save the contacts on the server 
      json = {
        :user => {
          :contacts => emails
        },
        :auth_token => @auth_token
      }.to_json

      on_api_call_failed = Proc.new { |json_obj|
        Logger.d("API CALL FAILED in ContactsSync.sync", ">")
      } 

      # Save on network
      network_post(CONFIG.get(:sync_contacts), nil, json, on_api_call_failed) do |response_obj|
        Logger.d("Contacts sync done", ":) ")
      end        
    }
  end



  # Finds all contacts in raw_contacts, get their sort_key (indexed field) 
  # Check on every sort_key if its an email
  # If so, it's a candidate for sync
  ## Non blocking call, runs in a different thread
  def find_all_contacts_with_email(&block)
    t = Thread.start do
      emails = []
      content_resolver = @context.get_content_resolver()
      cursor = content_resolver.query(ContactsContract::Contacts::CONTENT_URI, nil, nil, nil, nil)

      if cursor.get_count() > 0
        Logger.d("#{cursor.get_count} contacts are candidate for sync!")
        while cursor.moveToNext() do
          text = cursor.get_string(cursor.get_column_index("sort_key"))
          emails << text if is_contact_an_email?(text) == true
        end
        Logger.d("#{emails.length} contacts to actually sync!")
        
        block.call(emails)  # Invoke caller's block only when non-zero emails were found
      else
        Logger.d("NO contact to sync!")
      end
      cursor.close

    end # Thread ends
  end



  # Returns an array of all starred contacts in the system
  # [{:id => fetched_contact_id, :name => name, :phone_numbers => phones}, ...]
  def self.find_all_starred_contacts(context)
    content_resolver = context.get_content_resolver()
    cursor = content_resolver.query(ContactsContract::Contacts::CONTENT_URI, nil, "starred=1", nil, nil)
    Logger.d("Found starred contacts : " + cursor.get_count().to_s, "@")

    phone_number = ContactsContract::CommonDataKinds::Phone::NUMBER
    contact_id = "_id"
    phone_content_uri = ContactsContract::CommonDataKinds::Phone::CONTENT_URI
    phone_contact_id = ContactsContract::CommonDataKinds::Phone::CONTACT_ID

    starred_contacts = []

    if cursor.get_count > 0
      while cursor.move_to_next() do
        # Get the raw contact ID
        fetched_contact_id = cursor.get_string(cursor.get_column_index(contact_id))
        phone_cursor = content_resolver.query(phone_content_uri, nil, 
                                              phone_contact_id + " = #{fetched_contact_id}", 
                                              nil, nil)
        phones = []
        name = cursor.get_string(cursor.get_column_index("sort_key"))

        # Get the attached phone numbers to the contact ID. There can be more than one phone per contact
        while phone_cursor.move_to_next do
          phone_number_string = phone_cursor.get_string(phone_cursor.get_column_index(phone_number))
          phones << phone_number_string
          #Logger.d("#{cursor.get_string(cursor.get_column_index("sort_key"))} => #{phone_number_string}")
        end

        starred_contacts << {"id" => fetched_contact_id, 
                              "name" => name, "phone_number" => phones.first, 
                              "klass" => :starred_contact}

        phone_cursor.close
      end # while
    end # if

    cursor.close

    #Logger.d(starred_contacts.to_json, "+")
    return starred_contacts
  end



  private

  # Confirms if the given contact is an email or not
  def is_contact_an_email?(text)
    regex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
    return (text =~ regex).nil? ? false : true
  end



end