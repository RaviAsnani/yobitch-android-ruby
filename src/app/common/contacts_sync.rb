require "app/boot"

java_import 'android.provider.ContactsContract'


# Handles the contacts syncing
class ContactsSync
  attr_accessor :context

  def initialize(context)
    @context = context
    find_all_contacts_with_email
  end


  # See http://stackoverflow.com/questions/5205999/android-get-a-cursor-only-with-contacts-that-have-an-email-listed-android-2-0
  # See http://stackoverflow.com/questions/5457699/cursor-adapter-and-sqlite-example
  def find_all_contacts_with_email
    content_resolver = @context.get_content_resolver()
    projection = [
                    "_id", 
                    ContactsContract::Contacts::DISPLAY_NAME,
                    ContactsContract::Contacts::PHOTO_ID,
                    ContactsContract::CommonDataKinds::Email::DATA, 
                    ContactsContract::CommonDataKinds::Photo::CONTACT_ID
                  ]

    order = "CASE WHEN " 
            + ContactsContract::Contacts::DISPLAY_NAME 
            + " NOT LIKE '%@%' THEN 1 ELSE 2 END, " 
            + ContactsContract::Contacts::DISPLAY_NAME 
            + ", " 
            + ContactsContract::CommonDataKinds::Email.DATA
            + " COLLATE NOCASE"

    filter = ContactsContract::CommonDataKinds::Email::DATA + " NOT LIKE ''"
    cursor = content_resolver.query(ContactsContract::CommonDataKinds::Email::CONTENT_URI, 
                                      projection, filter, nil, order)



  end

end