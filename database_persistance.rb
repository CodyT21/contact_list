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
      SELECT contacts.*, groups.group_name
      FROM contacts
      LEFT JOIN groups ON contacts.id = groups.contact_id
      WHERE contacts.id = $1
    SQL

    result = query(sql, id)
    tuple_to_contact_hash(result.first)
  end

  def all_contacts
    sql = <<~SQL
      SELECT contacts.*, groups.group_name
      FROM contacts
      LEFT JOIN groups ON contacts.id = groups.contact_id
      ORDER BY contacts.id
    SQL

    result = query(sql)
    result.map do |tuple|
      tuple_to_contact_hash(tuple)
    end
  end

  def create_new_contact(first_name, last_name, phone, email, group=nil)
  end

  def update_contact(id, first_name, last_name, phone, email, group=nil) 
  end

  def delete_contact_at_id(id)
    sql = "DELETE FROM contacts WHERE id = $1"
    query(sql, id)
  end

  def all_group_names
    sql = "SELECT DISTINCT group_name FROM groups WHERE group_name IS NOT NULL"
    result = query(sql)
    result.map { |tuple| tuple['group_name']}
  end

  private

  def tuple_to_contact_hash(tuple)
    { id: tuple['id'], 
      first_name: tuple['first_name'],
      last_name: tuple['last_name'],
      phone_number: tuple['phone_number'],
      email_address: tuple['email'],
      group_name: tuple['group_name'] }
  end
end
