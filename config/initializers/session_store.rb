# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.



ActionController::Base.session = {
  :key         => '_webtop_session',
  :secret      => '7c77fc115b2229aa883273c6569ac9e088d35e7edf240e733665d7eb5180e6cc223a4d89ff228ebc0c67779939ed2d17e4bbbba1c6f8c5aefda34476ee43a725'
}

# ActionController::Base.session_options[:expire_after]=1.days


# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

ActionController::Base.session_store = :data_mapper_store 
