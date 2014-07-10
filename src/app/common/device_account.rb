require "app/boot"

java_import 'android.accounts.AccountManager'
java_import 'android.provider.ContactsContract'
java_import 'android.database.Cursor'
java_import 'android.net.Uri'

class DeviceAccount

  attr_accessor :context

  def initialize(context)
    @context = context
  end


  def get_user_details
    return {
      :name => get_account_name,
      :email => get_google_emails(:primary)
    }    
  end


  # If style is :primary, return the first email available. Else, return all
  def get_google_emails(style = :primary)
    manager = AccountManager.get(@context)
    accounts = manager.get_accounts_by_type("com.google")
    emails = []
    accounts.each { |account|
      emails.push(account.name)
      Logger.d(account.to_s)
    }

    return(style == :primary ? emails[0] : emails )
  end


  # Get account name from the device
  def get_account_name
    name = "User"
    
    begin
      cursor = @context
                .get_content_resolver()
                .query(ContactsContract::Profile::CONTENT_URI, nil, nil, nil, nil)
      cursor.moveToFirst();
      name = cursor.get_string(cursor.get_column_index("display_name"))
      cursor.close
    rescue Exception
    end

    return name
  end

end