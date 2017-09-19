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

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
    *
    FROM
    users
    WHERE
    fname = ? AND lname = ?
    SQL

    User.new(data.first)
  end


  def initialize(options)
    @id = options['id']
    @fname = options["fname"]
    @lname = options["lname"]
  end


  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
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
    Question.new(data.first)
  end

  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id )
    SELECT
      *
    FROM
      questions
    WHERE
      user_id = ?
    SQL
    Question.new(data.first)
  end

  def initialize(options)
    @id = options['id']
    @title = options["title"]
    @body = options["body"]
    @user_id = options["user_id"]
  end

  def author
    User.find_by_id(@user_id)
  end

  def replies
    Reply.find_by_question_id(@id)
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
    QuestionFollow.new(data.first)
  end

  def self.followers_for_question_id(q_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, q_id)
    SELECT
      *
    FROM
      users
    JOIN
      question_follows ON question_follows.user_id = users.id
    WHERE
      question_follows.q_id = ?
    SQL
    p data
    users = []
    data.each do |datum|
      users << User.new(datum)
    end
    users
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

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
    *
    FROM
    replies
    WHERE
    id = ?
    SQL
    Reply.new(data.first)
  end

  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      replies
    WHERE
      user_id = ?
    SQL
    Reply.new(data.first)
  end


  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      replies
    WHERE
      q_id = ?
    SQL
    Reply.new(data.first)
  end



  def initialize(options)
    @id = options['id']
    @q_id = options["q_id"]
    @user_id = options["user_id"]
    @reply_parent_id = options["reply_parent_id"]
    @body = options["body"]
  end


  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@q_id)
  end

  def parent_reply
    raise "Error" unless @reply_parent_id
    Reply.find_by_id(@reply_parent_id)
  end

  def child_replies
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      *
    FROM
      replies
    WHERE
      reply_parent_id = ?
    SQL
    p data
    Reply.new(data.first)
  end

end

class QuestionLikes
  attr_accessor :q_id, :user_id
  attr_reader :id

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
    *
    FROM
    question_likes
    WHERE
    id = ?
    SQL
    QuestionLikes.new(data.first)
  end

  def initialize(options)
    @id = options['id']
    @q_id = options["q_id"]
    @likes = options["likes"]
    @user_id = options["user_id"]
  end

end
