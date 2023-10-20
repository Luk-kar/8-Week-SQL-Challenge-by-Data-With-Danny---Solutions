/*
A. Enterprise Relationship Diagram

Using the following DDL schema details to create an ERD for all the Clique Bait datasets.
to access the DB Diagram tool to create the ERD.

*/

Table event_identifier {
  event_type integer
  event_name VARCHAR(13)
}

Table campaign_identifier {
  created_at timestamp
  campaign_id INTEGER
  products VARCHAR(3)
  campaign_name VARCHAR(33)
  start_date TIMESTAMP
  end_date TIMESTAMP
}

Table page_hierarchy {
  page_id INTEGER
  page_name VARCHAR(14)
  product_category VARCHAR(9)
  product_id INTEGER
}

Table users {
  user_id INTEGER
  cookie_id VARCHAR(6)
  start_date TIMESTAMP
}

Table events {
  visit_id VARCHAR(6)
  cookie_id VARCHAR(6)
  page_id INTEGER
  event_type INTEGER
  sequence_number INTEGER
  event_time TIMESTAMP
}


Ref: event_identifier.event_type > events.event_type // one-to-many

Ref: page_hierarchy.page_id > events.page_id // one-to-many

Ref: users.cookie_id > events.cookie_id // one-to-many

Ref: campaign_identifier.start_date > events.event_time // one-to-many

Ref: campaign_identifier.end_date > events.event_time // one-to-many

Ref: campaign_identifier.start_date > users.start_date // one-to-many

Ref: campaign_identifier.end_date > users.start_date // one-to-many 