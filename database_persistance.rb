require 'pg'

class DatabasePeristance
  def initialize(logger)
    @db = PG.connect(dbname: 'contacts')
    @logger = logger
  end

  def query(statement, *params)
    @logger.info("#{statement}: #{params}")
    @db.exec(statement, params)
  end

  def find_contact(id)
    sql = <<~SQL
      SELECT contacts.*, groups.name
        FROM contacts
        LEFT JOIN groups ON contacts.id = groups.contact_id
        WHERE contacts.id = $1
    SQL

    result = query(sql, id)
    tuple_to_contact_hash(result.first)
  end

  def all_contacts
    sql = <<~SQL
      SELECT contacts.*, groups.name
        FROM contacts
        LEFT JOIN groups ON contacts.id = groups.contact_id
        ORDER BY contacts.id
    SQL

    result = query(sql)
    result.map do |tuple|
      tuple_to_contact_hash(tuple)
    end
  end

  def create_new_contact(first_name, last_name, phone, email, group_name=nil)
    sql = <<~SQL
      INSERT INTO contacts (first_name, last_name, phone_number, email)
        VALUES ($1, $2, $3, $4)
    SQL
    query(sql, first_name, last_name, phone, email)
    
    add_contact_group(group_name) if group_name
  end
  
  def add_contact_group(group_name)
    sql = <<~SQL
      INSERT INTO groups (name, contact_id)
        VALUES ($1, (SELECT MAX(id) FROM contacts))
    SQL
    query(sql, group_name)
  end

  def update_contact(id, first_name, last_name, phone, email, group_name=nil)
    sql = <<~SQL
      UPDATE contacts
        SET first_name = $1,
        last_name = $2,
        phone_number = $3,
        email = $4
        WHERE id = $5
    SQL
    query(sql, first_name, last_name, phone, email, id)
    update_contact_group(group_name, id)
  end

  def update_contact_group(group_name, contact_id)
    sql = "UPDATE groups SET name = $1 WHERE contact_id = $2"
    query(sql, group_name, contact_id)
  end

  def delete_contact_at_id(id)
    sql = "DELETE FROM contacts WHERE id = $1"
    query(sql, id)
  end

  def all_group_names
    sql = "SELECT DISTINCT name FROM groups WHERE name IS NOT NULL"
    result = query(sql)
    result.map { |tuple| tuple['name']}
  end

  private

  def tuple_to_contact_hash(tuple)
    { id: tuple['id'], 
      first_name: tuple['first_name'],
      last_name: tuple['last_name'],
      phone_number: tuple['phone_number'],
      email_address: tuple['email'],
      group_name: tuple['name'] }
  end
end
