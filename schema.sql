CREATE TABLE contacts (
  id serial PRIMARY KEY,
  first_name varchar(100) NOT NULL,
  last_name varchar(100),
  phone_number varchar(11) NOT NULL CHECK (LENGTH(phone_number) BETWEEN 10 AND 11),
  email varchar(100) NOT NULL
);

CREATE TABLE groups (
  id serial PRIMARY KEY,
  group_name varchar(100) NOT NULL,
  contact_id integer NOT NULL REFERENCES contacts (id) ON DELETE CASCADE
);
