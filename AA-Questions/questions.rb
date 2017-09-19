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

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def save
    unless @id
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
            UPDATE
              users
            SET
              fname = ?, lname = ?
            WHERE
              id = ?
          SQL
    end
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

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
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

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def save
    unless @id
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO
        questions (title, body, user_id)
      VALUES
        (?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
            UPDATE
              questions
            SET
              title = ?, body = ?, user_id = ?
            WHERE
              id = ?
          SQL
    end
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

  def self.followed_questions_for_user_id(user_id)
    # want all the followed questions of a certain user
    #gives us all the
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
    *
    FROM
    questions
    JOIN
    question_follows ON questions.id = question_follows.q_id
    WHERE
    question_follows.user_id = ?
    SQL

    questions = []
    data.each do |datum|
      questions << Question.new(datum)
    end
    questions
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
    *
    FROM
    question_follows
    JOIN
    questions ON questions.id = question_follows.q_id
    GROUP BY
    q_id
    ORDER BY
    COUNT(question_follows.user_id) DESC
    LIMIT ?
    SQL

    questions = []
    data.each do |datum|
      questions << Question.new(datum)
    end
    questions
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

class QuestionLike
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
    QuestionLike.new(data.first)
  end

  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
    *
    FROM
    question_likes
    JOIN
    users ON users.id = user_id
    WHERE
    q_id = ?
    SQL

    user = []
    data.each do |datum|
      user << User.new(datum)
    end
    user
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
    COUNT(users.id)
    FROM
    question_likes
    JOIN
    users ON users.id = user_id
    WHERE
    q_id = ?
    SQL
    data.first.values.first
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      question_likes
    JOIN
      questions ON questions.id = q_id
    WHERE
      question_likes.user_id = ?
    SQL
    questions = []
    data.each do |datum|
      questions << Question.new(datum)
    end
    questions
  end


  def initialize(options)
    @id = options['id']
    @q_id = options["q_id"]
    @likes = options["likes"]
    @user_id = options["user_id"]
  end

end
