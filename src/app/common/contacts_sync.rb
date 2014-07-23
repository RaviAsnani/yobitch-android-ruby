require "app/boot"

java_import 'android.provider.ContactsContract'


# Handles the contacts syncing
class ContactsSync
  attr_accessor :context

  def initialize(context)
    @context = context
    find_all_contacts_with_email { |emails|
      # Save the contacts on the server 
      Logger.d(emails)
    }
  end


  # Finds all contacts in raw_contacts, get their sort_key (indexed field) 
  # Check on every sort_key if its an email
  # If so, it's a candidate for sync
  def find_all_contacts_with_email(&block)
    emails = []
    cr = @context.get_content_resolver()
    cur = cr.query(ContactsContract::Contacts::CONTENT_URI, nil, nil, nil, nil)
    if cur.get_count() > 0
      Logger.d("#{cur.get_count} contacts are candidate for sync!")
      while cur.moveToNext() do
        text = cur.get_string(cur.get_column_index("sort_key"))
        emails << text if is_contact_an_email?(text) == true
      end
      Logger.d("#{emails.length} contacts to actually sync!")
    else
      Logger.d("NO contact to sync!")
    end
    cur.close
    block.call(emails)
  end



  # Confirms if the given contact is an email or not
  def is_contact_an_email?(text)
    regex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
    return (text =~ regex).nil? ? false : true
  end

end