require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_accessor :fname, :lname
  attr_reader :id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
      *
      FROM
      users
      WHERE
      id = ?
    SQL
    p data
    User.new(data.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options["fname"]
    @lname = options["lname"]
  end

end


class Question
  attr_accessor :title, :body, :user_id
  attr_reader :id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
      *
      FROM
      questions
      WHERE
      id = ?
    SQL
    p data
    Question.new(data.first)
  end

  def initialize(options)
    @id = options['id']
    @title = options["title"]
    @body = options["body"]
    @user_id = options["user_id"]
  end

  # def self.all
  #   data = PlayDBConnection.instance.execute("SELECT * FROM plays")
  #   data.map { |datum| Play.new(datum) }
  # end

end

class QuestionFollow
  attr_accessor :q_id, :user_id
  attr_reader :id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
      *
      FROM
      question_follows
      WHERE
      id = ?
    SQL
    p data
    Question.new(data.first)
  end

  def initialize(options)
    @id = options['id']
    @q_id = options["q_id"]
    @user_id = options["user_id"]
  end

end

class Reply
  attr_accessor :body, :q_id, :user_id, :reply_parent_id
  attr_reader :id

end

class QuestionLikes
  attr_accessor :q_id, :user_id, :likes
  attr_reader :id

end
